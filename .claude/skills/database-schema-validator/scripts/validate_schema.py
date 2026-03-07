import re
import sys


def validate_schema(filename: str) -> int:
    try:
        with open(filename, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: file '{filename}' not found")
        return 1

    errors = []

    if re.search(r"DROP\\s+TABLE", content, re.IGNORECASE):
        errors.append("ERROR: DROP TABLE is forbidden")

    table_defs = re.finditer(
        r"CREATE\\s+TABLE\\s+(?P<name>\\w+)\\s*\\((?P<body>.*?)\\);",
        content,
        re.DOTALL | re.IGNORECASE,
    )

    for match in table_defs:
        table_name = match.group("name")
        body = match.group("body")

        if not re.match(r"^[a-z][a-z0-9_]*$", table_name):
            errors.append(f"ERROR: table '{table_name}' must be snake_case")

        if not re.search(r"\\bid\\b[^,\\n]*PRIMARY\\s+KEY", body, re.IGNORECASE):
            errors.append(f"ERROR: table '{table_name}' is missing id PRIMARY KEY")

    if errors:
        for err in errors:
            print(err)
        return 1

    print("Schema validation passed")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python scripts/validate_schema.py <schema_file>")
        raise SystemExit(1)

    raise SystemExit(validate_schema(sys.argv[1]))
