import csv
import json


def read_csv_to_dict(file_path):
    result_list = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            result_list.append(row)
    return result_list


def read_jsonfile(jsonfile):
    with open(jsonfile) as json_datafile:
        json_data = json.load(json_datafile)
        return(json_data)


def read_txt_file_to_string(file_path):
    with open(file_path, 'r') as txtfile:
        str_data = txtfile.read()
        return str_data
