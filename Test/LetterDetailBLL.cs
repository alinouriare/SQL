using KartablMVC.Classes;
using KartablMVC.Core;
using KartablMVC.Data;
using KartablMVC.ViewModel.Home;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace KartablMVC.BLL.Home
{
    public class LetterDetailBLL
    {
        public ReadMokatebehVM GetMokatebehDetails(Guid IdMokatebeh, int NoeMokatebeh, long GroupErja = 0, int IdChart = 0)
        {
            try
            {
                DetailsMokatebehVM vm = new DetailsMokatebehVM();

                using (ERPEntities db = new ERPEntities("ReadERPEntities"))
                {
                    var _resultIsValidUser = db.Database.SqlQuery<int>(
                     @"EXEC [SpKartabl].[IsValidUserToMokatebe]
                             @IdMokatebe,@IdPersonel",

                       new SqlParameter("@IdMokatebe", IdMokatebeh),
                       new SqlParameter("@IdPersonel", SM.General.IdPersonel)
                     ).FirstOrDefault();
                    if (_resultIsValidUser == 0)
                    {
                        return null;
                    }
                }

                using (ERPEntities db = new ERPEntities())
                {
                    var _resultDakheliInsert = db.Database.SqlQuery<string>(
                      @"EXEC [SpKartabl].[ChangeMokatebehStatus]
                             @IdMokatebeh,@IdNoeMokatebeh,@GroupErja,@IdPersonelReciver,@IdChartReciver",

                        new SqlParameter("@IdMokatebeh", IdMokatebeh),
                        new SqlParameter("@IdNoeMokatebeh", NoeMokatebeh),
                        new SqlParameter("@GroupErja", GroupErja),
                        new SqlParameter("@IdPersonelReciver", SM.General.IdPersonel),
                        new SqlParameter("@IdChartReciver", IdChart)
                      ).FirstOrDefault();
                }

                using (ERPEntities db = new ERPEntities())
                {
                    var idpersonel = int.Parse(SM.General.IdPersonel);
                    var _EventMokatebeh = db.EventMokatebeh.Where(x => x.IdMokatebeh == IdMokatebeh && x.IdPersonelReceiver == idpersonel && x.Status == false).ToList();
                    if (_EventMokatebeh != null)
                    {
                        foreach (var item in _EventMokatebeh)
                        {
                            item.Status = true;
                        }
                        db.SaveChanges();
                    }
                }

                using (ERPEntities db = new ERPEntities("ReadERPEntities"))
                {
                    var QQ = db.MultipleResults(@"EXEC [SpKartabl].GetDetailsMokatebeh @IdMokatebeh,@IdNoeMokatebeh,@GroupErja,@IdPersonel",
                        new SqlParameter[] {
                            new SqlParameter("@IdMokatebeh", IdMokatebeh),
                            new SqlParameter("@IdNoeMokatebeh", NoeMokatebeh),
                            new SqlParameter("@GroupErja", GroupErja),
                            new SqlParameter("@IdPersonel", int.Parse(SM.General.IdPersonel))
                        }).AddResult<DetailsMokatebehVM>().AddResult<ErjaMokatebehVM>().AddResult<PeyvastMokatebehVM>().Execute();

                    var MokatebehDetails = ((DetailsMokatebehVM[])QQ[0]).ToList();
                    var MokatebehErja = ((ErjaMokatebehVM[])QQ[1]).ToList();
                    var MokatebehPeyvast = ((PeyvastMokatebehVM[])QQ[2]).ToList();



                    ReadMokatebehVM read = new ReadMokatebehVM
                    {
                        DetailsMokatebeh = MokatebehDetails,
                        ErjaMokatebeh = MokatebehErja,
                        PeyvastMokatebeh = MokatebehPeyvast
                    };

                    return read;
                }
            }
            catch (Exception ex)
            {
                return new ReadMokatebehVM();
            }
        }



        public string GetPrintFileUrl(Guid IdMokatebeh, int NoeMokatebeh, long GroupErja = 0, bool ShowparaphsPrint = true, bool TodayDate = false)
        {
            try
            {
                DetailsMokatebehVM vm = new DetailsMokatebehVM();
                using (ERPEntities db = new ERPEntities("ReadERPEntities"))
                {
                    var QQ = db.MultipleResults(@"EXEC [SpKartabl].GetDetailsMokatebehForPrint @IdMokatebeh,@IdNoeMokatebeh,@GroupErja",
                        new SqlParameter[] {
                            new SqlParameter("@IdMokatebeh", IdMokatebeh),
                            new SqlParameter("@IdNoeMokatebeh", NoeMokatebeh),
                            new SqlParameter("@GroupErja", GroupErja)
                        }).AddResult<DetailsMokatebehVM>().AddResult<ErjaMokatebehVM>().Execute();

                    var MokatebehDetails = ((DetailsMokatebehVM[])QQ[0]).ToList();
                    var MokatebehErja = ((ErjaMokatebehVM[])QQ[1]).ToList();



                    string[] Field = new string[] { "Shomareh", "Tarikh", "Peyvast", "HtmlMatn", "HtmlEmza", "HtmlRoonevesht", "HtmlParaf" };
                    object[] data;

                    if (iFTP.EnsureLocalFileExistence(MokatebehDetails[0].PrintTemplate) == "")
                    {
                        return null;
                    }

                    if (MokatebehDetails[0].PrintTemplate.Contains("English"))
                    {

                        string newshomare = string.Empty;
                        if (MokatebehDetails[0].Shomareh != null)
                        {
                            string[] splitshomare = MokatebehDetails[0].Shomareh.Split('/');
                            newshomare = splitshomare[0] + "/" + splitshomare[1] + "/" + splitshomare[2] + "/" + splitshomare[3];
                        }

                        string newtdate = MokatebehDetails[0].CreateShamsiDate.Substring(0, 10);
                        data = new object[] {
                                            string.IsNullOrEmpty(newshomare)? "": newshomare.LatinNumber(),
                                            iDate.ConvertPersianDateToGregorianDate(newtdate),
                                            "",
                                            MokatebehDetails[0].Body,
                                            getEmzaFormatHtmlEN(MokatebehDetails),
                                            string.IsNullOrEmpty(MokatebehDetails[0].Roonevesht)?"":  MokatebehDetails[0].Roonevesht,
                                            ShowparaphsPrint ? getParaphs(MokatebehErja,ShowparaphsPrint) :""
                                       };
                    }
                    else
                    {

                        data = new object[] {
                                            string.IsNullOrEmpty(MokatebehDetails[0].Shomareh)? "":  MokatebehDetails[0].Shomareh.ConvertPersianNumber(),
                                            TodayDate ?iDate.ShamsiDateNow().ConvertPersianNumber(): MokatebehDetails[0].CreateShamsiDate.Substring(0,10).ConvertPersianNumber(),
                                            "",
                                             PreMatnName+ MokatebehDetails[0].Body+PostMatnename,
                                            getEmzaFormatHtmlFA(MokatebehDetails),
                                            string.IsNullOrEmpty(MokatebehDetails[0].Roonevesht)?"": PreMatnName+ "رونوشت : <P>" +  (MokatebehDetails[0].Roonevesht==null?"":MokatebehDetails[0].Roonevesht) + "</p>" +PostMatnename,
                                            ShowparaphsPrint ? getParaphs(MokatebehErja,ShowparaphsPrint) :""
                                       };
                    }


                    string path = iAspose.BuildPrintLetter(Field, data, MokatebehDetails[0].PrintTemplate, PIGIS_Context.Directory_Temp, "pdf");
                    return path;
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }
        static string PreMatnName = "<div align=\"right\" dir=\"rtl\"><p>";
        static string PostMatnename = "</p></div>";
        public static string getEmzaFormatHtmlFA(List<DetailsMokatebehVM> list)
        {

            if (list.Count > 0)
            {
                int i = 0;

                string parafString = "<table width=\"100%\" style=\"width:100%; line-height:1;font-family:'B Nazanin';font-size:11pt \"><tr>";
                foreach (var item in list)
                {
                    i++;

                    parafString += "<td width=\"25%\" style=\"padding-left: 75px; \"><span><img width=\"105\" height=\"105\" src=\""
                    + (item.IsErjaSadere == 1 ? item.EmzaReciver : item.EmzaUrl) + "\"/></span><br/><span>"
                    + 
                    (item.IsErjaSadere == 1 ? item.FullNameReciver : (item.SematName == "رییس هیئت مدیره" ? item.LastName : item.FirstName + " " + item.LastName)) + "</span> <br><span>"
                    + (item.IsErjaSadere == 1 ? item.SematNameReciver : item.SematName) + "</span><br/>"
                    + "</td>";

                    if (i % 3 == 0)
                    {
                        parafString += "</tr><tr>";
                    }
                }

                return parafString += "</tr></table>";
            }
            return "";
        }

        public static string getEmzaFormatHtmlEN(List<DetailsMokatebehVM> list)
        {
            if (list.Count > 0)
            {
                int i = 0;

                string parafString = "<table  width=\"100%\" style=\"width:100%; line-height:1;text-align: justify; direction: ltr;font-family:'B Nazanin';font-size:13pt \"><tr>";
                foreach (var item in list)
                {
                    i++;

                    parafString += "<td><div align=\"center\" style=\"line-height:1\"<span><img width=\"105\" height=\"105\" src=\""
                    + item.EmzaUrl + "\"/></span><br/><span>"
                     + "Sincerely," + "</span> <br> <span>"
                    + "Mohammad VatanDoust" + "</span> <br> <span>"
                    + "Chairman of the Board" + "</span><br/>"
                    + "</div></td>";

                    if (i % 3 == 0)
                    {
                        parafString += "</tr><tr>";
                    }
                }

                return parafString += "</tr></table>";
            }
            return "";
        }
        public static string getParaphs(List<ErjaMokatebehVM> MokatebehErja, bool GetForPrint = false)
        {
            DataTable dtParaphs = new DataTable();

            if (MokatebehErja.Count > 0)
            {
                var uri = HttpContext.Current.Request.Url;
                string host = uri.GetLeftPart(UriPartial.Authority);
                string parafString = "<table  width=\"100%\" style=\"width:100%; line-height:1;text-align: justify; direction: rtl;font-family:'B Nazanin';font-size:9pt \"><tr>";
                int i = 0;
                foreach (var item in MokatebehErja)
                {
                    i++;
                    string mozoParaf = (item.Description == null ? "" : item.Description.ToString());
                    string matnParaf = (!string.IsNullOrEmpty(item.MatnTarifParaf.ToString())) ? ((item.MatnTarifParaf.ToString().EndsWith(".")) ? "؛ " + item.MatnTarifParaf.ToString() : "؛ " + item.MatnTarifParaf.ToString() + ".") : "";
                    string emzaimage = (item.EmzaSender == null ? "" : item.EmzaSender.ToString().Replace("~", host));
                    string peyvastParaf = string.Empty;

                    parafString += "<td width=\"29%\" style=\"width: 29%; float: right; margin-right: 15px;line-height:1\"><span>"
                        + item.ReciverFullName + " " + mozoParaf + matnParaf + "</span>";

                    if (GetForPrint)
                    {
                        parafString += "<div align=\"center\" style=\"line-height:1\"><span>"
                            + item.NameSematSender.ToString() + "</span> - <span>"
                            + item.SenderFullName.ToString() + "</span><span><img width=\"100\" height=\"100\" src=\""
                            + (item.EmzaSender == null ? "" : item.EmzaSender.ToString().Replace("~", host)) + "\"/></span><br/>"
                            + item.PersonelSenderZamaneErsalShamsi.ToString().Substring(0, 10).ConvertPersianNumber() + peyvastParaf + "</div></td>";
                    }
                    else
                    {
                        parafString += "<div align=\"center\" style=\"line-height:1\"><span>"
                            + item.NameSematSender.ToString() + "</span> - <span>"
                            + item.SenderFullName.ToString() + "</span><span><img width=\"100\" height=\"100\" src=\""
                            + (item.EmzaSender == null ? "" : item.EmzaSender.ToString()) + "\"/></span><br/>"
                            + item.PersonelSenderZamaneErsalShamsi.ToString().Substring(0, 10).ConvertPersianNumber() + peyvastParaf + "</div></td>";
                    }
                    if (i % 3 == 0)
                    {
                        parafString += "</tr><tr>";
                    }
                }
                return parafString += "</tr></table>";
            }
            else return "";
        }

        public string SaveComment(Guid IdMokatebeh, string Comment)
        {
            try
            {
                DetailsMokatebehVM vm = new DetailsMokatebehVM();
                using (ERPEntities db = new ERPEntities())
                {
                    var _result = db.Database.SqlQuery<string>(
                        @"EXEC [SpKartabl].[InsertMokatebehComment]
                             @IdPersonel,@IdMokatebeh,@IdLanguage,@MokatebehComment",

                          new SqlParameter("@IdPersonel", SM.General.IdPersonel),
                          new SqlParameter("@IdMokatebeh", IdMokatebeh),
                          new SqlParameter("@IdLanguage", SystemSetting.IdLanguage),
                          new SqlParameter("@MokatebehComment", Comment)
                        ).FirstOrDefault();
                    return _result;
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public List<Emza> GetListEmza()
        {
            try
            {
                using (ERPEntities db = new ERPEntities("ReadERPEntities"))
                {
                    var _result = db.Database.SqlQuery<Emza>(
                        @"EXEC [SpKartabl].[GetListEmza]
                             @IdPersonel",
                          new SqlParameter("@IdPersonel", SM.General.IdPersonel)
                        ).ToList();
                    return _result;
                }
            }
            catch (Exception ex)
            {
                return new List<Emza>();
            }
        }

        public Transfer GetListTransition()
        {
            try
            {
                using (ERPEntities db = new ERPEntities("ReadERPEntities"))
                {
                    Transfer vm = new Transfer();
                    vm.NoeErsalDaryaft = db.ParameterMokatebehOptionLanguage.Where(x => x.IdParameterMokatebeh == 1).Select(x => new SelectListItem
                    {
                        Value = x.Id.ToString(),
                        Text = x.Name
                    }).ToList();

                    return vm;
                }
            }
            catch (Exception ex)
            {
                return new Transfer();
            }
        }
        public string SendConfirmation(Guid IdMokatebeh, Guid IdEmza, bool status)
        {
            try
            {
                DetailsMokatebehVM vm = new DetailsMokatebehVM();
                using (ERPEntities db = new ERPEntities())
                {
                    var _result = db.Database.SqlQuery<string>(
                        @"EXEC [SpKartabl].[MokatebehSaderehTaeid]
                             @IdMokatebeh,@IdPersonelReciver,@Status,@IdEmza",
                          new SqlParameter("@IdMokatebeh", IdMokatebeh),
                          new SqlParameter("@IdPersonelReciver", SM.General.IdPersonel),
                          new SqlParameter("@Status", status),
                          new SqlParameter("@IdEmza", IdEmza)
                        ).FirstOrDefault();
                    return _result;
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public string SendTransition(Guid IdMokatebe, int IdNoeErsalDaryaft, string NoeErsalDaryaftValue)
        {
            try
            {
                using (ERPEntities db = new ERPEntities())
                {
                    var _result = db.Database.SqlQuery<string>(
                        @"EXEC [SpKartabl].[UpdateNoeErsalDaryaft]
                             @IdMokatebeh,@IdNoeErsalDaryaft,@NoeErsalDaryaftValue",
                          new SqlParameter("@IdMokatebeh", IdMokatebe),
                          new SqlParameter("@IdNoeErsalDaryaft", IdNoeErsalDaryaft),
                          new SqlParameter("@NoeErsalDaryaftValue", NoeErsalDaryaftValue)
                        ).FirstOrDefault();
                    return _result;
                }
            }
            catch (Exception ex)
            {
                return null;
            }
        }
    }
    public class emzaha
    {
        public string semat { get; set; }
        public string namePersonel { get; set; }
        public string emza { get; set; }
    }
    public class Emza
    {
        public Guid Id { get; set; }
        public int IdPersonel { get; set; }
        public string Url { get; set; }
        public int Sort { get; set; }
    }
    public class Transfer
    {
        public Guid? IdMokatebat { get; set; }
        public string SelectedIdNoeErsalDaryaft { get; set; }
        public IEnumerable<SelectListItem> NoeErsalDaryaft { get; set; }
        public string NoeErsalDaryaftValue { get; set; }
    }
}