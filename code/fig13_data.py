from commonlibs_py.helpers import list_to_dict_by_key
from commonlibs_py.data_exporters import write_dictlist_csv
from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.canon_helpers import (
    get_top_n_canon_work_ids,
    get_canon_estc_ids)


def get_subject_topic_categories(
        subject_topic_data,
        subject_topic_level='st_final',
        only_handcurated=True):
    st_categories = set()
    for entry in subject_topic_data:
        if len(entry[subject_topic_level]) == 0:
            continue
        if only_handcurated:
            if entry[subject_topic_level][0].isupper():
                st_categories.add(entry[subject_topic_level])
        else:
            st_categories.add(entry[subject_topic_level])
    return list(st_categories)


def add_st_to_workdata(workdata, st_data_by_work_id):
    for item in workdata:
        if item['finalWorkField'] in st_data_by_work_id.keys():
            item['subject_topic'] = (
                st_data_by_work_id[item['finalWorkField']][0]['st_final'])
            item['subject_topic_simple'] = (
                st_data_by_work_id[item['finalWorkField']][0]['st_final_s'])
        else:
            item['subject_topic'] = ''
            item['subject_topic_simple'] = ''


def get_publisher_subject_topic_counts(
        actor_id, accepted_categories, accepted_categories_simple,
        actorlinks_by_actor_id, workdata_with_st_by_estc_id):
    st_counts = {}
    st_s_counts = {}
    for accepted_category in accepted_categories:
        st_counts[accepted_category] = 0
    for accepted_category in accepted_categories_simple:
        st_s_counts[accepted_category] = 0
    st_counts['uncategorized'] = 0
    st_counts['total_discounting_uncategorized'] = 0
    st_s_counts['uncategorized'] = 0
    st_s_counts['total_discounting_uncategorized'] = 0
    for actorlink in actorlinks_by_actor_id[actor_id]:
        if actorlink['curives'] not in workdata_with_st_by_estc_id.keys():
            continue
        if actorlink['primary_publisher'] == "True":
            this_st = workdata_with_st_by_estc_id[
                actorlink['curives']][0]['subject_topic']
            this_st_s = workdata_with_st_by_estc_id[
                actorlink['curives']][0]['subject_topic_simple']
            if this_st in accepted_categories:
                st_counts[this_st] += 1
                st_counts['total_discounting_uncategorized'] += 1
            else:
                st_counts['uncategorized'] += 1
            if this_st_s in accepted_categories_simple:
                st_s_counts[this_st_s] += 1
                st_s_counts['total_discounting_uncategorized'] += 1
            else:
                st_s_counts['uncategorized'] += 1
    st_shares = {}
    for key, value in st_counts.items():
        if key == 'total_discounting_uncategorized':
            continue
        if st_counts['total_discounting_uncategorized'] == 0:
            st_shares[key] = 0
        else:
            st_shares[key] = (
                value / st_counts['total_discounting_uncategorized'])
    st_s_shares = {}
    for key, value in st_s_counts.items():
        if key == 'total_discounting_uncategorized':
            continue
        if st_s_counts['total_discounting_uncategorized'] == 0:
            st_s_shares[key] = 0
        else:
            st_s_shares[key] = (
                value / st_s_counts['total_discounting_uncategorized'])
    return {
        'subject_topic_counts': st_counts,
        'subject_topic_percentages': st_shares,
        'subject_topic_simple_counts': st_s_counts,
        'subject_topic_simple_percentages': st_s_shares,
    }


# input datafiles
workdata_csv = "../data/raw/estc_works_roles.csv"
actorlinks_csv = "../data/raw/unified_actorlinks_enriched.csv"
canon_csv = "../data/work/canon.csv"

# from: data_prep_work_genres.py
subject_topic_data_csv = '../data/work/work_subject_topics_combined.csv'
# from: data_prep_publisher_canon_shares.py
publisher_canon_data_csv = (
    '../data/work/canon_individual_publisher_counts_all.csv')

# read data from csv
actorlinks = read_csv_to_dict(actorlinks_csv)
actorlinks_by_actor_id = list_to_dict_by_key(actorlinks, 'actor_id')

workdata = read_csv_to_dict(workdata_csv)
workdata_by_estc_id = list_to_dict_by_key(workdata, 'system_control_number')

subject_topic_data = read_csv_to_dict(subject_topic_data_csv)
st_data_by_work_id = list_to_dict_by_key(subject_topic_data, 'work_id')
st_categories = get_subject_topic_categories(
    subject_topic_data, subject_topic_level='st_final', only_handcurated=True)
st_s_categories = get_subject_topic_categories(
    subject_topic_data,
    subject_topic_level='st_final_s',
    only_handcurated=True)


canon = read_csv_to_dict(canon_csv)
canon1000_work_ids = get_top_n_canon_work_ids(canon, 1000)
canon1000_estc_ids = get_canon_estc_ids(canon1000_work_ids, workdata)

publisher_canon_data = read_csv_to_dict(publisher_canon_data_csv)

add_st_to_workdata(workdata, st_data_by_work_id)

for entry in publisher_canon_data:
    entry_st_counts = get_publisher_subject_topic_counts(
        entry['actor_id'], st_categories, st_s_categories,
        actorlinks_by_actor_id, workdata_by_estc_id)
    entry['subject_topic_counts'] = entry_st_counts['subject_topic_counts']
    entry['subject_topic_percentages'] = (
        entry_st_counts['subject_topic_percentages'])
    entry['subject_topic_simple_counts'] = (
        entry_st_counts['subject_topic_simple_counts'])
    entry['subject_topic_simple_percentages'] = (
        entry_st_counts['subject_topic_simple_percentages'])


pub_can_st_out = []
for entry in publisher_canon_data:
    out_line = {}
    for key, value in entry.items():
        if key in ['subject_topic_counts', 'subject_topic_percentages',
                   'subject_topic_simple_counts',
                   'subject_topic_simple_percentages']:
            for subtop, count in value.items():
                outkey = key + "*" + subtop
                out_line[outkey] = count
        else:
            out_line[key] = value
    pub_can_st_out.append(out_line)


write_dictlist_csv(
    pub_can_st_out,
    "../data/work/canon_individual_publisher_counts_subject_topics_all.csv")
