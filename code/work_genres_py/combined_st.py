from commonlibs_py.data_importers import read_csv_to_dict
from commonlibs_py.helpers import (
    dictlist_keep_only_fields,
    list_to_dict_by_key,
    filter_rows_with_field_value
    )
from commonlibs_py.data_exporters import write_dictlist_csv


def main():
    print("Create combined genredata output.")
    tranls_table_csv = (
        '../data/work/subject_topic_translation_table.csv')
    work_st_estc_csv = '../data/work/work_subject_topics_from_estc.csv'
    work_st_manual_csv = '../data/work/canon.csv'

    work_st_estc = read_csv_to_dict(work_st_estc_csv)
    work_st_estc_by_work_id = list_to_dict_by_key(work_st_estc, 'work_id')

    work_st_manual = read_csv_to_dict(work_st_manual_csv)
    work_st_manual = dictlist_keep_only_fields(
        work_st_manual, ['work_titles', 'ddc_class_div_1', 'ddc_class'])
    work_st_manual = filter_rows_with_field_value(
        work_st_manual, 'ddc_class_div_1', '')
    work_st_manual_by_work_id = list_to_dict_by_key(
        work_st_manual, 'work_titles')

    transl_table = read_csv_to_dict(tranls_table_csv)
    transl_table_by_estc_st = list_to_dict_by_key(transl_table, 'st_estc')

    outlist = []
    for entry in work_st_estc:
        work_id = entry['work_id']
        st_estc = work_st_estc_by_work_id[work_id][0]['st_most_common']
        outdict = {'work_id': work_id,
                   'st_manual': '',
                   'st_manual_s': '',
                   'st_estc': st_estc,
                   'st_final': st_estc,
                   'st_final_s': st_estc,
                   'st_method': 'estc_most_common'}
        if work_id in work_st_manual_by_work_id.keys():
            st_man = work_st_manual_by_work_id[work_id][0][
                'ddc_class_div_1']
            st_man_s = work_st_manual_by_work_id[work_id][0]['ddc_class']
            outdict['st_manual'] = st_man
            outdict['st_manual_s'] = st_man_s
            outdict['st_final'] = st_man
            outdict['st_final_s'] = st_man_s
            outdict['st_method'] = 'hand_curated'
        else:
            if st_estc in transl_table_by_estc_st.keys():
                outdict['st_final'] = (
                    transl_table_by_estc_st[st_estc][0]['st_manual'])
                outdict['st_final_s'] = (
                    transl_table_by_estc_st[st_estc][0]['st_manual_s'])
                outdict['st_method'] = 'translation_table'
        outlist.append(outdict)

    write_dictlist_csv(
        outlist, '../data/work/work_subject_topics_combined.csv')


if __name__ == "__main__":
    main()
