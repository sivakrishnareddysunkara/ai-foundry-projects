# create_blob_datasource_mi.py
# pip install azure-identity azure-search-documents

from azure.identity import DefaultAzureCredential
from azure.search.documents.indexes import SearchIndexerClient
from azure.search.documents.indexes.models import (
    SearchIndexerDataSourceConnection,
    SearchIndexerDataContainer,
    SearchIndexer
)
import os

# ---------- CONFIG ----------
SEARCH_SERVICE_NAME = "testcmekenable"   # e.g. "mysearchsvc"
ENDPOINT = f"https://testcmekenable.search.windows.net"
INDEX_NAME = "my-secure-index2"
DATASOURCE_NAME = "my-sql-datasource"               # or blob/table/cosmos datasource
INDEXER_NAME = "my-indexer"
CONTAINER_NAME = "test"
# ResourceId of the storage account (no leading/trailing spaces; include trailing slash and semicolon per docs)
STORAGE_RESOURCE_ID = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/searchcmektest/;"

# If using user-assigned managed identity (optional), set this to the resource id of the user-assigned identity:
# USER_ASSIGNED_MI_ID = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<miName>"

# -----------------------------
credential = DefaultAzureCredential()
indexer_client = SearchIndexerClient(endpoint=ENDPOINT, credential=credential)

def create_blob_datasource_using_mi():
    # container config
    container = SearchIndexerDataContainer(name=CONTAINER_NAME)

    # For system-assigned MI: credentials.connection_string should be the ResourceId string
    ds = SearchIndexerDataSourceConnection(
        name=DATASOURCE_NAME,
        type="azureblob",
        credentials={"connectionString": STORAGE_RESOURCE_ID},
        container=container
    )

    # If you need to specify a user-assigned identity, add an 'identity' attribute (preview)
    # ds.identity = {
    #     "@odata.type": "#Microsoft.Azure.Search.DataUserAssignedIdentity",
    #     "userAssignedIdentity": USER_ASSIGNED_MI_ID
    # }

    print("Creating datasource (managed identity)...")
    created = indexer_client.create_datasource_connection(ds)
    print("Datasource created:", created.name)
    return created

def create_indexer_targeting_index(index_name):
    idxr = SearchIndexer(
        name=INDEXER_NAME,
        data_source_name=DATASOURCE_NAME,
        target_index_name=index_name
    )
    print("Creating indexer...")
    created = indexer_client.create_indexer(idxr)
    print("Indexer created:", created.name)
    return created

if __name__ == "__main__":
    # Create datasource using managed identity
    try:
        create_blob_datasource_using_mi()
    except Exception as e:
        print("Datasource creation failed (it may already exist):", e)

    # Note: index must exist before creating the indexer. Create an index first (not shown).
    # create_indexer_targeting_index("<your-index-name>")
