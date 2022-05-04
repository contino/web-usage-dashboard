import json

from src.json_encoder import convert_to_json, batch_convert_to_json


def test_batch_convert_to_json():
    file1 = open("sample_data/10_access_logs", 'r')
    data = file1.readlines()
    output = batch_convert_to_json(data)
    assert len(output.split('\n')) == 10


def test_batch_convert_to_json__invalid_input():
    data = ''
    output = batch_convert_to_json(data)
    assert output == ""


def test_convert_to_json():
    line = '197.200.145.108 - - [05/Apr/2022:11:38:57 +0200] "GET /icons/blank.gif HTTP/1.1" 404 221 ' \
           '"http://www.almhuette-raith.at/apache-log/" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 ' \
           '(KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36" "-" '
    output = json.loads(convert_to_json(line))
    assert output['ip'] == "197.200.145.108"
    assert output['status'] == "404"


def test_convert_to_json__invalid_input():
    line = '197.200.145.108'
    assert convert_to_json(line) is None


def test_convert_to_json__size_missing():
    line = '197.200.145.108 - - [05/Apr/2022:11:38:57 +0200] "GET /icons/blank.gif HTTP/1.1" 404 - ' \
           '"http://www.almhuette-raith.at/apache-log/" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 ' \
           '(KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36" "-" '
    output = json.loads(convert_to_json(line))

    assert output['size'] is None


def test_ip_with_domain_prefix_1():
    line = '145.219.89.34.bc.google.com - - [05/Apr/2022:11:38:57 +0200] "GET /icons/blank.gif HTTP/1.1" 404 221 ' \
           '"http://www.almhuette-raith.at/apache-log/" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 ' \
           '(KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36" "-" '

    output = json.loads(convert_to_json(line))

    assert output['ip'] == "145.219.89.34"


def test_ip_with_domain_prefix_2():
    line = '145.219.89.34 - - [05/Apr/2022:11:38:57 +0200] "GET /icons/blank.gif HTTP/1.1" 404 221 ' \
           '"http://www.almhuette-raith.at/apache-log/" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 ' \
           '(KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36" "-" '

    output = json.loads(convert_to_json(line))

    assert output['ip'] == "145.219.89.34"

def test_ip_with_domain_prefix_empty():
    line = '- - - [05/Apr/2022:11:38:57 +0200] "GET /icons/blank.gif HTTP/1.1" 404 221 ' \
           '"http://www.almhuette-raith.at/apache-log/" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 ' \
           '(KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36" "-" '

    output = json.loads(convert_to_json(line))

    assert output['ip'] is None
