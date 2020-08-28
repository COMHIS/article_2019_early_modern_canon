from commonlibs_py.helpers import list_to_dict_by_key


def get_good_estc_titles_with_vartypes(estc_titles):
    retlist = []
    for item in estc_titles:
        for key in item.keys():
            if key == "publication_year":
                if pubyear_validates(item[key]):
                    item[key] = int(item[key])
                    retlist.append(item)
    return retlist


def set_actorlink_vartypes(actorlinks):
    for actorlink in actorlinks:
        for key in actorlink.keys():
            if key[:11] == "actor_role_":
                if actorlink[key] == "True":
                    actorlink[key] = True
                elif actorlink[key] == "False":
                    actorlink[key] = False
                else:
                    print('Unexpected data: ' + actorlink['link_id'])
            if key == "primary_publisher":
                if actorlink[key] == "True":
                    actorlink[key] = True
                else:
                    actorlink[key] = False
            if key == "pubyear":
                if pubyear_validates(actorlink[key]):
                    actorlink[key] = int(actorlink[key])


def get_actorlinks_with_pubyears(actorlinks, pubyears):
    actorlinks_with_years = []
    for actorlink in actorlinks:
        if actorlink['curives'] in pubyears.keys():
            pubyear = pubyears[actorlink['curives']]
            if pubyear != "NA" and pubyear is not None:
                actorlink.update(
                    {'pubyear': pubyear})
                actorlinks_with_years.append(actorlink)
    return actorlinks_with_years


def pubyear_validates(pubyear, min_accepted=1200, max_accepted=1800):
    pubyear = str(pubyear)
    if not pubyear.isdigit():
        return False
    else:
        if int(pubyear) >= min_accepted and int(pubyear) <= max_accepted:
            return True
        else:
            return False


def add_pubyears(estc_maindata, pubyears, only_keep_valid=True):
    results = []
    for item in estc_maindata:
        if item['curives'] in pubyears.keys():
            item_pubyear = pubyears[item['curives']]
            item.update({'pubyear': item_pubyear})
            if only_keep_valid:
                if pubyear_validates(item_pubyear):
                    results.append(item)
            else:
                results.append(item)
    return results


def get_print_sequence_for_estcdata(estc_maindata, workdata):
    workdata_by_curives = list_to_dict_by_key(
        workdata, 'system_control_number')
    workdata_by_workid = list_to_dict_by_key(
        workdata, 'finalWorkField')
    estc_maindata_by_curives = list_to_dict_by_key(estc_maindata, 'curives')
    #
    workid_pubyears = dict()
    for curives in workdata_by_curives.keys():
        curives_workid_pair = workdata_by_curives[curives][0]['finalWorkField']
        work_pubyears = set()
        for entry in workdata_by_workid[curives_workid_pair]:
            if (entry['system_control_number'] in
                    estc_maindata_by_curives.keys()):
                pubyear = estc_maindata_by_curives[
                    entry['system_control_number']][0]['pubyear']
                if pubyear_validates(pubyear):
                    work_pubyears.add(int(pubyear))
        work_pubyears = list(work_pubyears)
        work_pubyears.sort()
        workid_pubyears[curives_workid_pair] = work_pubyears
    #
    resultdict = {}
    for entry in estc_maindata:
        this_pubyear_seq = None
        if entry['curives'] in workdata_by_curives.keys():
            if (workdata_by_curives[entry['curives']][0]['finalWorkField'] in
                    workid_pubyears.keys()):
                pubyear_seq = workid_pubyears[
                    workdata_by_curives[entry['curives']][0]['finalWorkField']]
                if pubyear_validates(entry['pubyear']):
                    if int(entry['pubyear']) in pubyear_seq:
                        this_pubyear_seq = pubyear_seq.index(
                            int(entry['pubyear'])) + 1
        # entry.update({'edition_pubyear_seq': this_pubyear_seq})
        if this_pubyear_seq is not None:
            resultdict[entry['curives']] = this_pubyear_seq
    return resultdict


def add_print_sequence_to_estcmaindata(estc_maindata, workdata):
    estc_priseqs = get_print_sequence_for_estcdata(estc_maindata, workdata)
    for entry in estc_maindata:
        if entry['curives'] in estc_priseqs.keys():
            entry_priseq = estc_priseqs[entry['curives']]
        else:
            entry_priseq = None
        entry.update({'edition_pubyear_seq': entry_priseq})
    return estc_maindata


def set_actorlinks_primary_publisher(actorlinks_by_curives):
    processed_actorlinks = []
    for curives in actorlinks_by_curives.keys():
        curives_actors = actorlinks_by_curives[curives]
        has_primary_publisher = False
        for actorlink in curives_actors:
            actorlink.update({'primary_publisher': "False"})
            if actorlink['actor_role_publisher'] == "True":
                has_primary_publisher = True
                actorlink.update({'primary_publisher': "True"})
        if not has_primary_publisher:
            for actorlink in curives_actors:
                if actorlink['actor_role_printer'] == "True":
                    actorlink.update({'primary_publisher': "True"})
        for actoirlink in curives_actors:
            processed_actorlinks.append(actorlink)
    return processed_actorlinks
