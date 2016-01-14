DELETE FROM global_property WHERE property = 'emrapi.sqlSearch.activePatients';
INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('emrapi.sqlSearch.activePatients',
'select distinct
  concat(pn.given_name,\' \', pn.family_name) as name,
  pi.identifier as identifier,
  concat("",p.uuid) as uuid,
  concat("",v.uuid) as activeVisitUuid
from visit v
  join person_name pn on v.patient_id = pn.person_id and pn.voided = 0
  join patient_identifier pi on v.patient_id = pi.patient_id
  join person p on p.person_id = v.patient_id
  join encounter e on v.visit_id = e.visit_id
  join location l on e.location_id=l.location_id
where v.date_stopped is null AND v.voided = 0 and l.uuid=${location_uuid}',
'Sql query to get list of active patients',
uuid());