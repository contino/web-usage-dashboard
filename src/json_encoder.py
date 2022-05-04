import re
import json

# Apache Access Log Format Definition
regex = r'^(\S+) (\S+) (\S+) \[([\w:/]+\s[+\-]\d{4})\] "(\S+) (\S+)\s*(\S+)?\s*" (\d{3}) (\S+) (\S+) \"(.*?)\"'
fields = ['ip', 'ui', 'usr', '@timestamp', 'method', 'rline', 'ver', 'status', 'size', 'referrer', 'user_agent']

actions = []


def convert_to_json(line):
    """
    Takes a single line of Apache Access Log in tsv format and convert it in to json
    :param line: single line of Apache Access Log in tsv format
    :return: single line of Apache Access Log in json format
    """
    m = re.match(regex, line)
    if m:
        data1 = m.groups(0)
        data2 = dict(zip(fields, data1))

        if data2['size'] == '-':
            data2['size'] = None

        data2 = fix_ip_format(data2)
        return json.dumps(data2)


def batch_convert_to_json(data):
    """
    Takes a multiple lines of Apache Access Log in tsv format and convert it in to json
    :param data: multiple lines of Apache Access Log in tsv format
    :return: multiple lines of Apache Access Log in json format
    """
    json_batch = ""
    x = len(data)

    for i in range(0, x - 1):
        json_record = convert_to_json(data[i])
        if json_record:
            json_batch = json_batch + json_record + "\n"

    return json_batch


def fix_ip_format(line):
    """
    If found, removes the domain name suffix from ip address
    :param line: log as json string
    :return: log as json string
    """
    ip = line['ip']
    fixed_ip = re.findall(r'[0-9]+(?:\.[0-9]+){3}', ip)
    if fixed_ip:
        line['ip'] = fixed_ip[0]
    else:
        line['ip'] = None
    return line
