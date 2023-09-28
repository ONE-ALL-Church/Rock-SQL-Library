DECLARE @ContentChannelId INT = 7279

UPDATE ContentChannelItem 
Set StructuredContent = '{
    "time": 1693635680553,
    "blocks": [
        {
            "id": "O-eAMZ049z",
            "type": "paragraph",
            "data": {
                "text": "“"
            }
        }
    ],
    "version": "2.22.1"
}'
WHERE ID = @ContentChannelId