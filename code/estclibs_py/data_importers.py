import csv


def read_estc_pub_years(csv_location, delimiter=","):
    # earlier delimiter was tab "\t"
    result_dict = {}
    with open(csv_location, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=delimiter)
        for row in reader:
            result_dict[row['system_control_number']] = (
                row['publication_year'])
    return result_dict


def read_estc_cleaned_initial(csv_location):
    resultlist = []
    with open(csv_location, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if row['system_control_number'][0:10] == "(CU-RivES)":
                outrow = {
                    'curives': row['system_control_number'],
                    'title': row['title'],
                    'pub_loc': row["publication_place"],
                    'pub_statement': row["publisher"]
                }
                resultlist.append(outrow)
    return resultlist
