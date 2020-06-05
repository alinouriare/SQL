using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string PersianDate(SqlDateTime miladiDate )
    {
        DateTime mDate = (DateTime)miladiDate;

        var persianCalendar =new System.Globalization.PersianCalendar();
       string pDate= persianCalendar.GetYear(mDate).ToString() + "/" + 
            persianCalendar.GetMonth(mDate).ToString("00")
            + "/" + persianCalendar.GetDayOfMonth(mDate).ToString("00");
        return pDate;
    }
}
