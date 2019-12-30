SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCategoryReport]
	-- Add the parameters for the stored procedure here
	@creatorUserId INT,
  @startDate DATETIME,
  @endDate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SUM(Amount) as Total,
    PvCategory.Name as CategoryName,
    PvCategory.Icon as CategoryIcon,
    PvAccount.Name as AccountName,
    PvCurrency.Code as CurrencyCode
  FROM PvTransaction
    INNER JOIN  PvCategory on PvTransaction.CategoryId = PvCategory.Id
    INNER JOIN  PvAccount on PvTransaction.AccountId = PvAccount.Id
    INNER JOIN PvCurrency on PvAccount.CurrencyId = PvCurrency.Id
  WHERE PvTransaction.CreatorUserId=@creatorUserId
        and TransactionTime> @startDate
        and TransactionTime< @endDate
        and PvTransaction.IsDeleted=0
        and PvTransaction.IsTransferred=0
        and PvTransaction.Amount<0
  GROUP BY PvCategory.Name,PvCategory.Icon, PvAccount.Name,  PvCurrency.Code
  ORDER BY PvCategory.Name
END
GO
