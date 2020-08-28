def set_estc_titles_subject_topics(estc_titles, subject_topics_by_work_id):
    for estc_title in estc_titles:
        this_work_id = estc_title['work_id']
        # this_subject_topic = None
        if (this_work_id is None or
                this_work_id not in subject_topics_by_work_id.keys()):
            estc_title['subject_topic_s'] = None
            estc_title['subject_topic'] = None
        else:
            estc_title['subject_topic_s'] = (
                subject_topics_by_work_id[this_work_id][0]['st_final_s'])
            estc_title['subject_topic'] = (
                subject_topics_by_work_id[this_work_id][0]['st_final'])
