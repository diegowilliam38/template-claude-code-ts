import re
import sys
from pathlib import Path


TEMPLATE_PATH = Path(__file__).resolve().parent.parent / "resources" / "ToolTemplate.py.hbs"


def normalize_name(raw: str) -> str:
    parts = re.findall(r"[A-Za-z0-9]+", raw)
    if not parts:
        raise ValueError("Invalid tool name")
    return "".join(p.capitalize() for p in parts)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python scripts/scaffold_tool.py <ToolName>")
        return 1

    tool_name = normalize_name(sys.argv[1])
    class_name = f"{tool_name}Tool"
    output_name = f"{class_name}.py"

    template = TEMPLATE_PATH.read_text(encoding="utf-8")
    content = template.replace("{{CLASS_NAME}}", class_name).replace("{{TOOL_NAME}}", tool_name.lower())

    output_path = Path.cwd() / output_name
    output_path.write_text(content, encoding="utf-8")

    print(f"Generated {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
