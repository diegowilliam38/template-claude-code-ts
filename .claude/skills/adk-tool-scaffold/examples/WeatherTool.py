from typing import Any, Dict


class WeatherTool:
    name = "weather"
    description = "Fetches weather information for a city"

    def get_schema(self) -> Dict[str, Any]:
        return {
            "type": "object",
            "properties": {
                "city": {"type": "string"},
            },
            "required": ["city"],
        }

    def execute(self, **kwargs: Any) -> Dict[str, Any]:
        city = kwargs.get("city", "")
        return {"ok": True, "data": {"city": city, "temperature_c": 25}}
