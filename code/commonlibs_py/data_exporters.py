import csv


def write_dictlist_csv(dictlist, csvpath):
    with open(csvpath, 'w') as csvfile:
        fieldnames = list(dictlist[0].keys())
        writer = csv.DictWriter(csvfile, fieldnames)
        writer.writeheader()
        for item in dictlist:
            writer.writerow(item)
