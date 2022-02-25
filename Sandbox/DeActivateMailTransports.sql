-- DEACTIVATE ALL MAIL TRANSPORTS --
BEGIN
UPDATE [AttributeValue] SET [Value] = 'False' 
WHERE AttributeId IN 
    (SELECT a.id 
    FROM [EntityType] et 
    INNER JOIN [Attribute] a 
    ON a.EntityTypeId = et.Id AND a.[Key] = 'Active' 
    WHERE et.name LIKE '%Communication.Transport%')
END