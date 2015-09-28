begin tran
UPDATE dbo.COMM_DETAIL
SET intCommTypeID = 25
WHERE     (intCommTypeID = 20) AND (intMemberID IN
                       (SELECT     intMemberID
                            FROM          MEMBER
                            WHERE      (dtStart < '10/1/2014')))
rollback