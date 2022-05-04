from elasticsearch import Elasticsearch, RequestsHttpConnection, helpers
import json
from json_encoder import convert_to_json
from typing import Dict
import secrets


class EsDataLoader:

    def __init__(self, region, host, service, index, index_type, awsauth):
        self.region = region
        self.host = host
        self.service = service
        self.index = index
        self.index_type = index_type
        self.awsauth = awsauth

        self.es_client = Elasticsearch(
            hosts=[{'host': self.host, 'port': 443}],
            http_auth=awsauth,
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection)

        print(self.es_client.ping())
        print(json.dumps(self.es_client.info(), indent=2))

    def create_index(self, index_name: str, mapping: Dict) -> None:
        """
        Create an ES index if not exists.
        :param index_name: Name of the index.
        :param mapping: Mapping of the index
        """
        res = self.es_client.indices.exists(self.index)
        print("Index Exists ... {}".format(res))
        if res is False:
            print(f"Creating index {index_name} with the following schema: {json.dumps(mapping, indent=2)}")
            self.es_client.indices.create(index=index_name, ignore=400, body=mapping)

    def populate_index(self, data: str) -> None:
        """
        Populate an index from a CSV file.
        :param data: log data in tsv format.
        :param index_name: Name of the index to which documents should be written.
        """

        actions = []
        count = 0
        for line in data:
            line = line.decode("utf-8")
            document = convert_to_json(line)
            action = {
                "_index": self.index,
                '_op_type': 'index',
                "_type": self.index_type,
                "_id": secrets.token_hex(16),
                "_source": document
            }
            actions.append(action)
            count = count + 1
            if len(actions) > 10000:
                helpers.bulk(self.es_client, actions)
                actions = []
                print('Completed indexing ' + str(count) + " log entries..")

        if len(actions) > 0:
            helpers.bulk(self.es_client, actions)

        print('Completed indexing ' + str(count) + " log entries..")
