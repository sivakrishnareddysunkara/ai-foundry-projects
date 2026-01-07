
import os
import sys
from azure.identity import DefaultAzureCredential
from azure.ai.contentsafety import ContentSafetyClient
from azure.ai.contentsafety.models import AnalyzeTextOptions, AnalyzeImageOptions
from azure.core.exceptions import HttpResponseError

ENDPOINT = "https://content-safety1234546.cognitiveservices.azure.com/"
if not ENDPOINT:
    print("Missing AZURE_CONTENT_SAFETY_ENDPOINT variable.", file=sys.stderr)
    sys.exit(1)

credential = DefaultAzureCredential()
client = ContentSafetyClient(endpoint=ENDPOINT, credential=credential)

def pretty_print_categories(cat_list):
    """
    cat_list: iterable of TextCategoriesAnalysis-like objects (has .category and .severity and maybe .matches)
    """
    if not cat_list:
        print("  (no categories_analysis returned)")
        return
    for cat in cat_list:
        # attribute names from SDK: category, severity, maybe details/matches depending on response
        name = getattr(cat, "category", "<unknown>")
        severity = getattr(cat, "severity", None)
        print(f" - {name}: severity = {severity}")
        # try to show matched spans / details if present
        # different SDK versions may store matches under 'matched_text', 'matches', or 'match_details'
        matches = getattr(cat, "matches", None) or getattr(cat, "match_details", None) or getattr(cat, "matched_text", None)
        if matches:
            print("   matches:")
            # matches may be list of objects or strings
            if isinstance(matches, (list, tuple)):
                for m in matches:
                    # try to print sensible representation
                    try:
                        # if m is object with text attribute
                        txt = getattr(m, "text", None) or getattr(m, "match_text", None) or str(m)
                        print(f"    * {txt}")
                    except Exception:
                        print(f"    * {m}")
            else:
                print(f"    * {matches}")

def analyze_text_content(text: str):
    print("\n ANALYZING TEXT...\n")
    print("INPUT:", text, "\n")
    options = AnalyzeTextOptions(text=text)
    try:
        result = client.analyze_text(options)
    except HttpResponseError as ex:
        print("HTTP error from Content Safety:", ex, file=sys.stderr)
        return
    except Exception as ex:
        print("Unexpected error calling analyze_text:", ex, file=sys.stderr)
        return

    # NEW: use categories_analysis (list) — correct property for AnalyzeTextResult
    categories = getattr(result, "categories_analysis", None)
    print("Text categories_analysis:")
    pretty_print_categories(categories)

    # Blocklist matches (if any)
    blocklists = getattr(result, "blocklists_match", None) or getattr(result, "blocklist_matches", None)
    if blocklists:
        print("\n Blocklist matches:")
        for bl in blocklists:
            # fields can include: blocklist_name, blocklist_text, blocklist_item_id
            name = getattr(bl, "blocklist_name", getattr(bl, "blocklistName", None))
            text_match = getattr(bl, "blocklist_text", getattr(bl, "blocklistText", None)) or getattr(bl, "blocklistItemText", None)
            print(f" - {name}: {text_match}")

def analyze_image_content(image_path: str):
    print("\n ANALYZING IMAGE...\n")
    if not os.path.exists(image_path):
        print("Image file not found:", image_path, file=sys.stderr)
        return
    try:
        with open(image_path, "rb") as f:
            # SDK convenience method accepts a stream or AnalyzeImageOptions
            result = client.analyze_image(f)
    except HttpResponseError as ex:
        print("HTTP error from Content Safety (image):", ex, file=sys.stderr)
        return
    except Exception as ex:
        print("Unexpected error calling analyze_image:", ex, file=sys.stderr)
        return

    categories = getattr(result, "categories_analysis", None)
    print("Image categories_analysis:")
    pretty_print_categories(categories)

if __name__ == "__main__":
    print("testing Azure Content Safety endpoint with sample text and image.")

    test_text = "I am going to kill you."
    analyze_text_content(test_text)
    test_image = "test_image.jpg"
    analyze_image_content(test_image)
    print("\n Done.")
