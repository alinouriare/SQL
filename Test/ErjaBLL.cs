using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using KartablMVC.ViewModel.Home.Erja;
using KartablMVC.Core;
using KartablMVC.Data;
using KartablMVC.ViewModel.Home.General;
using KartablMVC.ViewModel.Home.Peyvast;
using System.Data.SqlClient;

namespace KartablMVC.BLL.Home
{
    public class ErjaBLL
    {
        public enum VaziateEghdam
        {
            No = 24,
            Yes = 25
        }
        public enum VaziatMokatebeh
        {
            UnRead = 30,
            Read = 31,
            UnArchive = 32,
            Archive = 33
        }
        public LoadErjaVM GetErja(Guid Id, long? GroupErja)
        {
            try
            {
                LoadErjaVM vm = new LoadErjaVM();
                using (ERPEntities db = new ERPEntities())
                {
                    var _Mokatebeh = db.Mokatebeh.Where(x => x.Id == Id).FirstOrDefault();

                    vm.PersonelsTo = GeneralBLL.ShowAllSematForPersonelsWithGroup();
                    vm.Semats = GeneralBLL.GetSematActiveWithPersonelId(int.Parse(SM.General.IdPersonel));
                    vm.NoeParafs = GeneralBLL.GetNoeParaf();
                    vm.OnvanParafs = GeneralBLL.GetOnvanParafWithPersonelId(int.Parse(SM.General.IdPersonel));

                    vm.Subject = _Mokatebeh.MokatebehLanguage.Select(x => x.Subject).FirstOrDefault();
                    vm.Shomareh = _Mokatebeh.Shomareh;
                    vm.IdMokatebeh = _Mokatebeh.Id;
                    vm.GroupErja = GroupErja;
                    return vm;
                }
            }
            catch (Exception ex)
            {
                return new LoadErjaVM();
            }
        }

        public LoadErjaVM GetErjaForEdit(Guid Id, long GroupErja)
        {
            try
            {
                LoadErjaVM vm = new LoadErjaVM();
                using (ERPEntities db = new ERPEntities())
                {
                    var _Mokatebeh = db.Mokatebeh.Where(x => x.Id == Id).FirstOrDefault();
                    vm.ErjaReciver = db.Database
                        .SqlQuery<EditErjaReciverVM>(
                            @"EXEC [SpKartabl].[ShowReciverErja] @IdMokatebeh,@IdPersonelSender,@IdLanguage,@GroupErja",
                             new SqlParameter("@IdMokatebeh", Id),
                             new SqlParameter("@IdPersonelSender", int.Parse(SM.General.IdPersonel)),
                             new SqlParameter("@IdLanguage", SystemSetting.IdLanguage),
                             new SqlParameter("@GroupErja", GroupErja)

                            ).Select(x => new EditErjaReciverVM
                            {
                                Id = x.Id,
                                FullName = x.FullName,
                                PersonelIdChart = x.PersonelIdChart,
                                IdTarifParaf = x.IdTarifParaf,
                                MatnTarifParaf = x.MatnTarifParaf,
                                NameSemat = x.NameSemat,
                                TypeTarifParaf = x.TypeTarifParaf,
                                Description = x.Description
                            }).ToList();
                    vm.PersonelsTo = GeneralBLL.ShowAllSematForPersonelsWithGroup();
                    vm.Semats = GeneralBLL.GetSematActiveWithPersonelId(int.Parse(SM.General.IdPersonel));
                    vm.NoeParafs = GeneralBLL.GetNoeParaf();
                    vm.OnvanParafs = GeneralBLL.GetOnvanParafWithPersonelId(int.Parse(SM.General.IdPersonel));

                    int Idpersonel = int.Parse(SM.General.IdPersonel);
                    vm.SelectedIdChart = db.Erja.Where(x => x.IdMokatebeh == Id && x.IdPersonelSender == Idpersonel && x.GroupErja == GroupErja).Select(x => x.IdChartSender).FirstOrDefault().ToString();
                    vm.Subject = _Mokatebeh.MokatebehLanguage.Select(x => x.Subject).FirstOrDefault();
                    vm.Shomareh = _Mokatebeh.Shomareh;
                    vm.IdMokatebeh = _Mokatebeh.Id;
                    vm.GroupErja = GroupErja;
                    vm.Peyvast = db.Peyvast.Where(x => x.GroupErja == GroupErja).Select(x => new PeyvastVM()
                    {
                        Id = x.Id,
                        Url = x.Url
                    }).ToList();

                    return vm;
                }
            }
            catch (Exception ex)
            {
                return new LoadErjaVM();
            }
        }

        public string Insert(FormErjaVM model)
        {
            try
            {
                using (ERPEntities db = new ERPEntities())
                {
                    GenerateErjaVM _Generate = new GenerateErjaVM();
                    //string[] PersonelReciver = model.SelectedIdPersonelTo.Split(':');

                    long ticks = DateTime.Now.Ticks;
                    //if (model.GroupErja > 0)
                    //{
                    //    ticks = model.GroupErja.Value;
                    //}

                    foreach (var item in model.ErjaReciver)
                    {
                        if (item.IdPersonelTo.Contains(":"))
                        {
                            string[] PersonelCc = item.IdPersonelTo.Split(':');

                            _Generate.Erja.Add(new ErjaVM()
                            {
                                IdMokatebeh = model.IdMokatebeh,
                                IdPersonelSender = int.Parse(SM.General.IdPersonel),
                                IdChartSender = int.Parse(model.SelectedIdChart),
                                IdPersonelReciver = int.Parse(PersonelCc[0]),
                                IdChartReciver = int.Parse(PersonelCc[1]),
                                IdVaziatMokatebehSender = (int)VaziatMokatebeh.UnRead,
                                IdVaziatMokatebehReciver = (int)VaziatMokatebeh.UnRead,
                                IdVaziateEghdam = (int)VaziateEghdam.No,
                                SenderIP = Security.GetUserIP(),
                                ReciverIP = null,
                                PersonelSenderZamaneErsalShamsi = MD.PersianDateTime.PersianDateTime.Now.ToString("yyyy/MM/dd HH:mm:ss").LatinNumber(),
                                PersonelSenderZamaneErsalMiladi = DateTime.Now,
                                PersonelReciverZamaneDaryaftMiladi = null,
                                PersonelReciverZamaneDaryaftShamsi = null,
                                IdLanguage = SystemSetting.IdLanguage,
                                MatnParaf = item.MatnParaf,
                                IdNoeParaf = item.IdNoeParaf,
                                IdOnvanParaf = item.IdOnvanParaf,
                                OnvanParaf = item.OnvanParaf,
                                GroupErja = ticks
                            });
                        }
                        else
                        {
                            foreach (var x in db.LetterGroupRelation.AsNoTracking().Where(v => v.IdLetterGroup.ToString() == item.IdPersonelTo && v.IsActive == true).ToList())
                            {
                                _Generate.Erja.Add(new ErjaVM()
                                {
                                    IdMokatebeh = model.IdMokatebeh,
                                    IdPersonelSender = int.Parse(SM.General.IdPersonel),
                                    IdChartSender = int.Parse(model.SelectedIdChart),
                                    IdPersonelReciver = x.IdPersonel,
                                    IdChartReciver = x.IdChart,
                                    IdVaziatMokatebehSender = (int)VaziatMokatebeh.UnRead,
                                    IdVaziatMokatebehReciver = (int)VaziatMokatebeh.UnRead,
                                    IdVaziateEghdam = (int)VaziateEghdam.No,
                                    SenderIP = Security.GetUserIP(),
                                    ReciverIP = null,
                                    PersonelSenderZamaneErsalShamsi = MD.PersianDateTime.PersianDateTime.Now.ToString("yyyy/MM/dd HH:mm:ss").LatinNumber(),
                                    PersonelSenderZamaneErsalMiladi = DateTime.Now,
                                    PersonelReciverZamaneDaryaftMiladi = null,
                                    PersonelReciverZamaneDaryaftShamsi = null,
                                    IdLanguage = SystemSetting.IdLanguage,
                                    MatnParaf = item.MatnParaf,
                                    IdNoeParaf = item.IdNoeParaf,
                                    IdOnvanParaf = item.IdOnvanParaf,
                                    OnvanParaf = item.OnvanParaf,
                                    GroupErja = ticks
                                });
                            }
                        }
                    }


                    List<FileDetails> list = null;
                    if (HttpContext.Current.Session["UploadFileList"] != null)
                    {
                        list = HttpContext.Current.Session["UploadFileList"] as List<FileDetails>;
                        foreach (var item in list)
                        {
                            int TypeFile = 0;
                            if (item.Type == "peyvast")
                            {
                                TypeFile = 1;
                            }
                            else if (item.Type == "scan")
                            {
                                TypeFile = 2;
                            }
                            else if (item.Type == "erja")
                            {
                                TypeFile = 3;
                            }
                            string personelDirectory;
                            if (!string.IsNullOrEmpty(SM.General.Username.Trim()))
                                personelDirectory = SM.General.Username.Trim() + "/SCT/";
                            else
                                personelDirectory = "NoFolder" + "/SCT/";
                            item.Path = iFTP.UploadLocalFTP(item.File, iFTP.TypeUpload.FTP, PIGIS_Context.FolderMode.User, personelDirectory);
                            _Generate.Peyvast.Add(new PeyvastVM() { Id = Guid.Empty, IdMokatebe = model.IdMokatebeh, Url = item.Path, Type = TypeFile });
                        }
                    }
                    if (list != null && list.Where(w => w.Path.ToLower() == "error").Any())
                    {
                        foreach (var item in list)
                        {
                            iFTP.FtpDeleteFile(item.Path);
                            string fullPath = HttpContext.Current.Request.MapPath(item.Path);
                            if (System.IO.File.Exists(fullPath))
                            {
                                System.IO.File.Delete(fullPath);
                            }
                        }
                        return null;
                    }
                    string _ErjaInsertJson = Newtonsoft.Json.JsonConvert.SerializeObject(_Generate, Newtonsoft.Json.Formatting.Indented);

                    var _resultErjaInsert = db.Database.SqlQuery<string>(
                         @"EXEC [SpKartabl].[InsertMokatebehErja]
                             @MokatebehModel",

                           new SqlParameter("@MokatebehModel", _ErjaInsertJson)
                         ).FirstOrDefault();

                    return _resultErjaInsert;
                }
            }
            catch (Exception ex)
            {
                string error = "Message :" + ex.Message + Environment.NewLine + "StackTrace :" + ex.StackTrace;
                var result = ErrorLogBLL.InsertError(int.Parse(SM.General.IdPersonel), error);
                return "";
            }
        }

        public string Edit(FormErjaVM model)
        {
            try
            {
                using (ERPEntities db = new ERPEntities())
                {
                    GenerateErjaVM _Generate = new GenerateErjaVM();
                    //string[] PersonelReciver = model.SelectedIdPersonelTo.Split(':');

                    foreach (var item in model.ErjaReciver)
                    {
                        if (item.IdPersonelTo.Contains(":"))
                        {
                            string[] PersonelCc = item.IdPersonelTo.Split(':');

                            _Generate.Erja.Add(new ErjaVM()
                            {
                                IdMokatebeh = model.IdMokatebeh,
                                IdErja = item.Id,
                                Actions = item.Action,
                                IdPersonelSender = int.Parse(SM.General.IdPersonel),
                                IdChartSender = int.Parse(model.SelectedIdChart),
                                IdPersonelReciver = int.Parse(PersonelCc[0]),
                                IdChartReciver = int.Parse(PersonelCc[1]),
                                IdVaziatMokatebehSender = (int)VaziatMokatebeh.UnRead,
                                IdVaziatMokatebehReciver = (int)VaziatMokatebeh.UnRead,
                                IdVaziateEghdam = (int)VaziateEghdam.No,
                                SenderIP = Security.GetUserIP(),
                                ReciverIP = null,
                                PersonelSenderZamaneErsalShamsi = MD.PersianDateTime.PersianDateTime.Now.ToString("yyyy/MM/dd HH:mm:ss").LatinNumber(),
                                PersonelSenderZamaneErsalMiladi = DateTime.Now,
                                PersonelReciverZamaneDaryaftMiladi = null,
                                PersonelReciverZamaneDaryaftShamsi = null,
                                IdLanguage = SystemSetting.IdLanguage,
                                MatnParaf = item.MatnParaf,
                                IdNoeParaf = item.IdNoeParaf,
                                IdOnvanParaf = item.IdOnvanParaf,
                                OnvanParaf = item.OnvanParaf,
                                GroupErja = model.GroupErja.Value,
                            });
                        }
                        else
                        {
                            foreach (var x in db.LetterGroupRelation.AsNoTracking().Where(v => v.IdLetterGroup.ToString() == item.IdPersonelTo && v.IsActive == true).ToList())
                            {
                                _Generate.Erja.Add(new ErjaVM()
                                {
                                    IdMokatebeh = model.IdMokatebeh,
                                    IdErja = item.Id,
                                    Actions = item.Action,
                                    IdPersonelSender = int.Parse(SM.General.IdPersonel),
                                    IdChartSender = int.Parse(model.SelectedIdChart),
                                    IdPersonelReciver = x.IdPersonel,
                                    IdChartReciver = x.IdChart,
                                    IdVaziatMokatebehSender = (int)VaziatMokatebeh.UnRead,
                                    IdVaziatMokatebehReciver = (int)VaziatMokatebeh.UnRead,
                                    IdVaziateEghdam = (int)VaziateEghdam.No,
                                    SenderIP = Security.GetUserIP(),
                                    ReciverIP = null,
                                    PersonelSenderZamaneErsalShamsi = MD.PersianDateTime.PersianDateTime.Now.ToString("yyyy/MM/dd HH:mm:ss").LatinNumber(),
                                    PersonelSenderZamaneErsalMiladi = DateTime.Now,
                                    PersonelReciverZamaneDaryaftMiladi = null,
                                    PersonelReciverZamaneDaryaftShamsi = null,
                                    IdLanguage = SystemSetting.IdLanguage,
                                    MatnParaf = item.MatnParaf,
                                    IdNoeParaf = item.IdNoeParaf,
                                    IdOnvanParaf = item.IdOnvanParaf,
                                    OnvanParaf = item.OnvanParaf,
                                    GroupErja = model.GroupErja.Value,
                                });
                            }
                        }
                    }


                    List<FileDetails> list = null;
                    if (HttpContext.Current.Session["UploadFileList"] != null)
                    {
                        list = HttpContext.Current.Session["UploadFileList"] as List<FileDetails>;
                        foreach (var item in list)
                        {
                            int TypeFile = 0;
                            if (item.Type == "peyvast")
                            {
                                TypeFile = 1;
                            }
                            else if (item.Type == "scan")
                            {
                                TypeFile = 2;
                            }
                            else if (item.Type == "erja")
                            {
                                TypeFile = 3;
                            }
                            string personelDirectory;
                            if (!string.IsNullOrEmpty(SM.General.Username.Trim()))
                                personelDirectory = SM.General.Username.Trim() + "/SCT/";
                            else
                                personelDirectory = "NoFolder" + "/SCT/";
                            item.Path = iFTP.UploadLocalFTP(item.File, iFTP.TypeUpload.FTP, PIGIS_Context.FolderMode.User, personelDirectory);
                            _Generate.Peyvast.Add(new PeyvastVM() { Id = Guid.Empty, IdMokatebe = model.IdMokatebeh, Url = item.Path, Type = TypeFile });
                        }
                    }
                    if (list != null && list.Where(w => w.Path.ToLower() == "error").Any())
                    {
                        foreach (var item in list)
                        {
                            iFTP.FtpDeleteFile(item.Path);
                            string fullPath = HttpContext.Current.Request.MapPath(item.Path);
                            if (System.IO.File.Exists(fullPath))
                            {
                                System.IO.File.Delete(fullPath);
                            }
                        }
                        return null;
                    }
                    if (model.PeyvastRemove != null)
                    {
                        foreach (var item in model.PeyvastRemove)
                        {
                            _Generate.PeyvastRemove.Add(new PeyvastRemoveVM { Id = item });
                        }
                    }

                    string _ErjaInsertJson = Newtonsoft.Json.JsonConvert.SerializeObject(_Generate, Newtonsoft.Json.Formatting.Indented);

                    var _resultDakheliInsert = db.Database.SqlQuery<string>(
                         @"EXEC [SpKartabl].[UpdateMokatebehErja]
                             @MokatebehModel",

                           new SqlParameter("@MokatebehModel", _ErjaInsertJson)
                         ).FirstOrDefault();

                    return _resultDakheliInsert;
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }
    }
}