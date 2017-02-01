SELECT chw_user_registration AS 'CHW name',
       registered_users AS 'Number of patients captured',
       registered_users-patients_with_hid AS 'Number of patients without hid',
       IFNULL(health_id_issued_users,0) AS 'Number of hid cards issued'
FROM
  (SELECT count(*) AS registered_users,
          ur.username AS chw_user_registration
   FROM person pr
   INNER JOIN users ur ON pr.creator = ur.user_id
   INNER JOIN user_role urr ON ur.user_id = urr.user_id
   WHERE urr.role ='CHW'
     AND date(pr.date_created) BETWEEN '#startDate#' AND '#endDate#'
     AND pr.voided=0
   GROUP BY pr.creator) tr
LEFT OUTER JOIN
  (SELECT count(*) AS health_id_issued_users,
          ui.username AS chw_user_issuer
   FROM person pi
   INNER JOIN users ui ON pi.creator = ui.user_id
   INNER JOIN user_role uri ON ui.user_id = uri.user_id
   INNER JOIN person_attribute pai ON pi.person_id = pai.person_id
   INNER JOIN person_attribute_type pati ON pai.person_attribute_type_id = pati.person_attribute_type_id
   WHERE ROLE ='CHW'
     AND date(pi.date_created) BETWEEN '#startDate#' AND '#endDate#'
     AND name = 'hidCardIssued'
     AND pi.voided=0
     AND value = 'true'
   GROUP BY pi.creator) ti ON tr.chw_user_registration = ti.chw_user_issuer
LEFT OUTER JOIN
  (SELECT count(*) AS patients_with_hid,
          u.username AS chw_user
   FROM person p
   INNER JOIN patient_identifier pid ON p.person_id=pid.patient_id
   INNER JOIN users u ON p.creator = u.user_id
   INNER JOIN user_role urrr ON u.user_id = urrr.user_id
   WHERE urrr.role ='CHW'
     AND date(p.date_created) BETWEEN '#startDate#' AND '#endDate#'
     AND p.voided=0
     AND pid.identifier_type=(select patient_identifier_type_id  from patient_identifier_type where name='Health Id')
   GROUP BY p.creator ) hid ON tr.chw_user_registration = hid.chw_user;