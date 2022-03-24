DECLARE @StructuredC VARCHAR(MAX) = ''
SET @StructuredC = '
{"time":1647638587730,"blocks":[{"id":"hU0mRgubLT","type":"header","data":{"text":"Christian Education Weekend","level":2}},{"id":"z9X7mQPt9m","type":"paragraph","data":{"text":"&nbsp;"}},{"id":"x6psLvdVrC","type":"header","data":{"text":"Western Christian Schools","level":3}},{"id":"h-JZHGETfj","type":"paragraph","data":{"text":"Western&nbsp; Christian Schools exists to love the Lord Jesus Christ, to teach the truth, and to serve others.&nbsp;Located in the Inland Valley of CA, Western Christian Schools is an independent private day school for Preschool - 12th grade."}},{"id":"Fjt6Nzejcb","type":"note","data":{"id":"87bb9477-2074-48a5-bf86-77ae7ab854b4","note":""}},{"id":"PW1-tDxzJn","type":"header","data":{"text":"Sonrise Christian School","level":3}},{"id":"BRjd3Taf5h","type":"paragraph","data":{"text":"Our mission at Sonrise Christian School is to create an environment in which children can experience the love of Jesus as they grow in wisdom and stature and in favor with God and people."}},{"id":"H2zNyDsXBu","type":"note","data":{"id":"f7bd240e-d0aa-416f-b731-e2825b359d2b","note":""}},{"id":"WOxHf3Toma","type":"header","data":{"text":"Life Pacific University","level":3}},{"id":"0xZi77SW-t","type":"paragraph","data":{"text":"Life Pacific University is a WSCUC and ABHE accredited institution of biblical higher education existing for the transformational development of students into leaders prepared to serve God in the Church, the workplace, and the world."}},{"id":"80VY_7JUgr","type":"note","data":{"id":"2a486ace-ca03-4dfa-a518-b9dfd90566f6","note":""}},{"id":"PLT7UOJycM","type":"header","data":{"text":"Innovations Learning Academy","level":3}},{"id":"flqoe1uXYC","type":"paragraph","data":{"text":"Innovations Learning Academy creates an inclusive environment that provides personalized and flexible learning opportunities that extend the boundaries of traditional education while preparing students to successfully participate in their communities and society. We believe we are here to support and empower families to create personalized approaches to learning that meet the unique learning styles of their children while valuing flexibility and choice."}},{"id":"e5ag1XmCpx","type":"note","data":{"id":"65ec595b-e939-4b95-aa17-dc81018cb358","note":""}},{"id":"v5fhMJtjTm","type":"header","data":{"text":"The Feast of First Fruits","level":2}},{"id":"q7MJ-UlOtH","type":"note","data":{"id":"da421cbf-0089-4370-ba56-9376d77efe1b","note":""}}],"version":"2.22.1"}
'


SELECT @StructuredC


UPDATE ContentChannelItem
SET StructuredContent = @StructuredC
WHERE Id = 4252

SELECT *
FROM ContentChannelItem cci
WHERE cci.Id = 4252
