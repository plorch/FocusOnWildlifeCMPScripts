-- Name:  zooniverse_classification_choices
-- Comment:  Splits out answers of interest from complex jsonb fields from zooniverse_classification_nodups view. Creates new choice field where Z_NOTINGTHERE replaces NOTHINGTHERE so it sorts to the end, for tie breaking. Used to create a view for debugging.
SELECT *,
	CASE WHEN choice='NOTHINGTHERE' THEN 'Z_NOTHINGTHERE'
    	ELSE choice
        END as choice_z
    FROM(SELECT a.id,
		a.classification_id,
		a.workflow_id,
		a.workflow_name,
		a.workflow_version,
		a.metadata,
		a.subject_ids,
		jsonb_array_elements(jsonb_array_elements(annotations::jsonb)->'value')->>'choice' as choice,
		jsonb_array_elements(jsonb_array_elements(annotations::jsonb)->'value')->'answers' as answers,
		jsonb_array_elements(jsonb_array_elements(annotations::jsonb)->'value')->'answers'->'HOWMANY' as number_of_animals,
-- This is just to deal with the wierd use of subject_id as a key rather than a value
		jsonb_object_keys(subject_data::jsonb) as subject_id,
		replace(split_part(split_part(jsonb_each(subject_data::jsonb)::text,',"',2),'")',1),'""','"')::jsonb as subject_rest
	FROM camera_trap.zooniverse_classification_nodups as a) as b
-- WHERE subject_ids='5056764';
