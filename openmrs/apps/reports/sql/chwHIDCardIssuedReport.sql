SELECT chw_user_registration AS 'CHW Name',
       registered_users AS 'Number of Patients Registered',
       IFNULL(health_id_issued_users,0) AS 'Number of HealthId Card Issued'
FROM
  (SELECT count(*) AS registered_users,
          ur.username AS chw_user_registration
   FROM person pr
   INNER JOIN users ur ON pr.creator = ur.user_id
   INNER JOIN user_role urr ON ur.user_id = urr.user_id
   WHERE urr.role ='CHW'
     AND date(pr.date_created) BETWEEN '#startDate#' AND '#endDate#'
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
     AND value = 'true'
   GROUP BY pi.creator) ti ON chw_user_registration=chw_user_issuer;


