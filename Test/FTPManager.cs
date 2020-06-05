using Microsoft.AspNetCore.Http;
using PartonetMLM.Core.Utility;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net;

namespace PartonetMLM.Core.FTP
{
    public class FTPManager
    {
        public static string FTPHost { get { return "ftp://103.215.222.181:24"; } }
        public static string HttpHost { get { return "http://file.healthnotion.com"; } }
        private static string FtpUserName { get { return "ftphels"; } }
        private static string FtpPassword { get { return "#$@kjsdf564654G5421"; } }


        public static string UploadToFTP(IFormFile Attachment, string ftpurl, string FileName)
        {
            try
            {
                var request = (FtpWebRequest)WebRequest.Create(ftpurl + FileName);
                request.Method = WebRequestMethods.Ftp.UploadFile;
                request.Credentials = new NetworkCredential(FtpUserName, FtpPassword);
                request.UsePassive = true;
                request.UseBinary = true;
                request.KeepAlive = false;
                request.Timeout = 1000000000;
                request.ReadWriteTimeout = 1000000000;

                byte[] bytes;
                using (var ms = new MemoryStream())
                {
                    Attachment.CopyTo(ms);
                    bytes = ms.ToArray();
                    string s = Convert.ToBase64String(bytes);
                }
                var reqStream = request.GetRequestStream();
                reqStream.Write(bytes, 0, bytes.Length);
                reqStream.Close();

                return "ok";
            }
            catch (Exception exp)
            {
                return "error: " + exp.Message;
            }
        }

        public bool UploadToFtp(IFormFile file, string username, string password, string uploadurl, string newFileName = null)
        {
            try
            {
                var uploadfilename = string.IsNullOrEmpty(newFileName) ? file.FileName : newFileName;

                byte[] buffer;
                using (var ms = new MemoryStream())
                {
                    file.CopyTo(ms);
                    buffer = ms.ToArray();
                    string s = Convert.ToBase64String(buffer);
                }

                string ftpurl = String.Format("{0}/{1}", uploadurl, uploadfilename);
                var requestObj = FtpWebRequest.Create(ftpurl) as FtpWebRequest;
                requestObj.Method = WebRequestMethods.Ftp.UploadFile;
                requestObj.Credentials = new NetworkCredential(username, password);
                Stream requestStream = requestObj.GetRequestStream();
                requestStream.Write(buffer, 0, buffer.Length);
                requestStream.Flush();
                requestStream.Close();
                requestObj = null;

                return true;
            }
            catch (Exception exp) { return false; }
        }

        public bool UploadToFtp(IFormFileCollection fileColection, string uploadurl, string username, string password)
        {
            for (int index = 0; index < fileColection.Count; index++)
            {
                bool result = UploadToFtp(file: fileColection[index], username: username, password: password, uploadurl: uploadurl);
                if (result == false) return false;
            }

            return true;
        }

        /// <summary>
        /// آپلود عکس اصلی و سه سایز دیگر از آن 
        /// </summary>
        /// <param name="file"></param>
        /// <param name="uploadurl"></param>
        /// <param name="newFileName"></param>
        /// <returns></returns>
        public static bool UploadImageToFtp_WithResizeVersions(IFormFile file, string uploadurl, List<ImageSizeEnum> imageSizes, ImageFormat newFileFormat, string newFileName = null)
        {
            try
            {
                bool result = false;

                Image orgImg;
                using (var ms = new MemoryStream())
                {
                    file.CopyTo(ms);
                    orgImg = Image.FromStream(ms);
                }

                var uploadfilename = string.IsNullOrEmpty(newFileName) ? file.FileName : newFileName;

                result = UploadImageToFTP(orgImg, uploadurl, uploadfilename, newFileFormat);


                foreach (var size in imageSizes)
                {
                    string finalPath = uploadurl;
                    switch (size)
                    {
                        case ImageSizeEnum.Small: finalPath += ImageSize.SmallPath + "/"; break;
                        case ImageSizeEnum.Meduim: finalPath += ImageSize.MeduimPath + "/"; break;
                        case ImageSizeEnum.Large: finalPath += ImageSize.LargePath + "/"; break;
                    }

                    Bitmap _imgthumb = ImageResizer.ScaleImage(orgImg, size);

                    result = UploadImageToFTP(_imgthumb, finalPath, uploadfilename, newFileFormat);
                }

                return result;
            }
            catch (Exception exp)
            {
                return false;
            }
        }


        /// <summary>
        /// آپلود عکس بدون هیچ تغییری
        /// </summary>
        /// <param name="img"></param>
        /// <param name="uploadurl"></param>
        /// <param name="newFileName"></param>
        /// <returns></returns>
        public static bool UploadImageToFTP(Image img, string uploadurl, string newFileName, ImageFormat newFileFormat)
        {
            try
            {
                byte[] buffer;
                using (var ms = new MemoryStream())
                {
                    img.Save(ms, newFileFormat);
                    buffer = ms.ToArray();
                }


                string ftpurl = String.Format("{0}/{1}", uploadurl, newFileName);
                var requestObj = FtpWebRequest.Create(ftpurl) as FtpWebRequest;
                requestObj.Method = WebRequestMethods.Ftp.UploadFile;
                requestObj.Credentials = new NetworkCredential(FtpUserName, FtpPassword);
                Stream requestStream = requestObj.GetRequestStream();
                requestStream.Write(buffer, 0, buffer.Length);
                requestStream.Flush();
                requestStream.Close();
                requestObj = null;


                return true;
            }
            catch (Exception exp)
            {
                return false;
            }
        }






        public bool DeleteFile(string fileFullPath, string userName, string password)
        {
            if (CheckFileExistOrNot_FTP(fileFullPath, userName, password))
            {
                FtpWebRequest ftpRequest = (FtpWebRequest)WebRequest.Create(fileFullPath);
                ftpRequest.Credentials = new NetworkCredential(userName, password);
                ftpRequest.Method = WebRequestMethods.Ftp.DeleteFile;
                FtpWebResponse responseFileDelete = (FtpWebResponse)ftpRequest.GetResponse();

                return true;
            }

            return false;
        }

        public bool CheckFileExistOrNot_FTP(string fileFullPath, string username, string password)
        {
            FtpWebRequest ftpRequest = null;
            FtpWebResponse ftpResponse = null;
            bool IsExists = true;
            try
            {
                ftpRequest = (FtpWebRequest)WebRequest.Create(fileFullPath);
                ftpRequest.Credentials = new NetworkCredential(username, password);
                ftpRequest.Method = WebRequestMethods.Ftp.GetFileSize;
                ftpResponse = (FtpWebResponse)ftpRequest.GetResponse();
                ftpResponse.Close();
                ftpRequest = null;
            }
            catch (Exception ex)
            {
                IsExists = false;
            }
            return IsExists;
        }

        public bool CheckFileExistOrNot_HTTP(string fileFullPath)
        {
            //HttpWebRequest HttpRequest = null;
            //HttpWebResponse HttpResponse = null;
            //bool IsExists = true;
            //try
            //{
            //    HttpRequest = (HttpWebRequest)WebRequest.Create(fileFullPath);
            //    HttpRequest.Credentials = new NetworkCredential(SystemSetting.FTPUserName, SystemSetting.FTPPassword);
            //    //HttpRequest.Method = WebRequestMethods.Http.GetFileSize;
            //    HttpResponse = (HttpWebResponse)HttpRequest.GetResponse();
            //    HttpResponse.Close();
            //    HttpRequest = null;
            //}
            //catch (Exception ex)
            //{
            //    IsExists = false;
            //}
            //return IsExists;




            HttpWebResponse response = null;
            var request = (HttpWebRequest)WebRequest.Create(fileFullPath);
            request.Method = "HEAD";
            bool IsExists = true;

            try
            {
                response = (HttpWebResponse)request.GetResponse();
            }
            catch (WebException ex)
            {
                IsExists = false;
                /* A WebException will be thrown if the status of the response is not `200 OK` */
            }
            finally
            {
                // Don't forget to close your response.
                if (response != null)
                {
                    response.Close();
                }
            }

            return IsExists;
        }

        //public static string _iFTPMove(string UploadUrl, string UploadUrl2, string FileName)
        //{
        //    string FTPAddress = "ftp://103.215.222.181:24/";
        //    string FTPUsername = "FtpKartabl";
        //    string FTPPassword = "(tamjidi357456";

        //    FtpWebRequest ftpRequest = null;
        //    FtpWebResponse ftpResponse = null;
        //    try
        //    {
        //        string ftpurl = String.Format("{0}{1}{2}", FTPAddress, UploadUrl, FileName);
        //        var requestObj = FtpWebRequest.Create(ftpurl) as FtpWebRequest;

        //        ftpRequest.Credentials = new NetworkCredential(FTPUsername, FTPPassword);
        //        ftpRequest.UseBinary = true;
        //        ftpRequest.UsePassive = true;
        //        ftpRequest.KeepAlive = true;
        //        ftpRequest.Method = WebRequestMethods.Ftp.Rename;
        //        ftpRequest.RenameTo = UploadUrl2 + "/" + FileName;
        //        ftpResponse = (FtpWebResponse)ftpRequest.GetResponse();
        //        ftpResponse.Close();
        //        ftpRequest = null;
        //    }
        //    catch (Exception ex)
        //    {
        //        throw ex;
        //    }
        //    return "";
        //}

        public static string _iFTP(Image Attachment, string UploadUrl, string FileName)
        {
            string FTPAddress = "ftp://103.215.222.181:24/";
            string FTPUsername = "FtpKartabl";
            string FTPPassword = "(tamjidi357456";

            try
            {
                string ftpurl = String.Format("{0}{1}", FTPAddress, UploadUrl);
                var request = (FtpWebRequest)WebRequest.Create(ftpurl + FileName);
                request.Method = WebRequestMethods.Ftp.UploadFile;
                request.Credentials = new NetworkCredential(FTPUsername, FTPPassword);
                request.UsePassive = true;
                request.UseBinary = true;
                request.KeepAlive = false;
                request.Timeout = 1000000000;
                request.ReadWriteTimeout = 1000000000;
                byte[] buffer;
                using (MemoryStream ms = new MemoryStream())
                {
                    Attachment.Save(ms, ImageFormat.Jpeg);
                    buffer = ms.ToArray();
                    Stream streamObj = ms;

                    streamObj.Read(buffer, 0, buffer.Length);
                    streamObj.Close();
                    streamObj = null;
                }
                var reqStream = request.GetRequestStream();
                reqStream.Write(buffer, 0, buffer.Length);
                reqStream.Close();

                return "ok";
            }
            catch (Exception e)
            {
                return "error";
            }
        }


        //public static string _iFTP(Bitmap Attachment, string UploadUrl, string FileName)
        //{
        //    string FTPAddress = "ftp://103.215.222.181:24/";
        //    string FTPUsername = "FtpKartabl";
        //    string FTPPassword = "(tamjidi357456";
        //    byte[] buffer;
        //    using (MemoryStream ms = new MemoryStream())
        //    {
        //        Attachment.Save(ms, ImageFormat.Jpeg);
        //        buffer = ms.ToArray();
        //        Stream streamObj = ms;

        //        streamObj.Read(buffer, 0, buffer.Length);
        //        streamObj.Close();
        //        streamObj = null;
        //    }
        //    string ftpurl = String.Format("{0}{1}{2}", FTPAddress, UploadUrl, FileName);
        //    var requestObj = FtpWebRequest.Create(ftpurl) as FtpWebRequest;
        //    requestObj.Method = WebRequestMethods.Ftp.UploadFile;
        //    requestObj.Credentials = new NetworkCredential(FTPUsername, FTPPassword);
        //    requestObj.UsePassive = true;
        //    requestObj.UseBinary = true;
        //    requestObj.KeepAlive = false;
        //    requestObj.Timeout = 1000000000;
        //    requestObj.ReadWriteTimeout = 1000000000;
        //    Stream requestStream = requestObj.GetRequestStream();
        //    requestStream.Write(buffer, 0, buffer.Length);
        //    requestStream.Flush();
        //    requestStream.Close();
        //    return "";
        //}

        //public static string _iFTP(Bitmap Attachment, string UploadUrl, string FileName, ImageFormat imgformat)
        //{
        //    string FTPAddress = "ftp://103.215.222.181:24/";
        //    string FTPUsername = "FtpKartabl";
        //    string FTPPassword = "(tamjidi357456";
        //    byte[] buffer;
        //    using (MemoryStream ms = new MemoryStream())
        //    {
        //        Attachment.Save(ms, imgformat);
        //        buffer = ms.ToArray();
        //        Stream streamObj = ms;

        //        streamObj.Read(buffer, 0, buffer.Length);
        //        streamObj.Close();
        //        streamObj = null;
        //    }
        //    string ftpurl = String.Format("{0}{1}{2}", FTPAddress, UploadUrl, FileName);
        //    var requestObj = FtpWebRequest.Create(ftpurl) as FtpWebRequest;
        //    requestObj.Method = WebRequestMethods.Ftp.UploadFile;
        //    requestObj.Credentials = new NetworkCredential(FTPUsername, FTPPassword);
        //    requestObj.UsePassive = true;
        //    requestObj.UseBinary = true;
        //    requestObj.KeepAlive = false;
        //    requestObj.Timeout = 1000000000;
        //    requestObj.ReadWriteTimeout = 1000000000;
        //    Stream requestStream = requestObj.GetRequestStream();
        //    requestStream.Write(buffer, 0, buffer.Length);
        //    requestStream.Flush();
        //    requestStream.Close();
        //    requestObj = null;

        //    return "";
        //}

        //public static string _iFTPDelete(string UploadUrl, string FileName)
        //{
        //    try
        //    {
        //        string FTPAddress = "ftp://103.215.222.181:24/";
        //        string FTPUsername = "FtpKartabl";
        //        string FTPPassword = "(tamjidi357456";

        //        string ftpurl = String.Format("{0}{1}{2}", FTPAddress, UploadUrl, FileName);
        //        var requestObj = FtpWebRequest.Create(ftpurl) as FtpWebRequest;
        //        requestObj.Method = WebRequestMethods.Ftp.DeleteFile;
        //        requestObj.Credentials = new NetworkCredential(FTPUsername, FTPPassword);
        //        WebResponse reqResponse = requestObj.GetResponse();
        //    }
        //    catch (Exception)
        //    {

        //    }
        //    return "";
        //}
        ///// <summary>
        ///// متد چک و ایجاد دایرکتوری
        ///// </summary>
        ///// <param name="pathToCreate">مسیر دایرکتوری مورد نیاز</param>

        //public static void MakeFtpDir(string pathToCreate)
        //{
        //    string FTPAddress = "ftp://103.215.222.181:24/";
        //    string FTPUsername = "ftphels";
        //    string FTPPassword = "#$@kjsdf564654G5421";
        //    FtpWebRequest reqFTP = null;
        //    Stream ftpStream = null;
        //    string[] subDirs = pathToCreate.Split('/');
        //    string currentDir = FTPAddress;
        //    foreach (string subDir in subDirs)
        //    {
        //        try
        //        {
        //            currentDir = currentDir + "/" + subDir;
        //            reqFTP = (FtpWebRequest)FtpWebRequest.Create(currentDir);
        //            reqFTP.Method = WebRequestMethods.Ftp.MakeDirectory;
        //            reqFTP.UseBinary = true;
        //            reqFTP.Credentials = new NetworkCredential(FTPUsername, FTPPassword);
        //            FtpWebResponse response = (FtpWebResponse)reqFTP.GetResponse();
        //            ftpStream = response.GetResponseStream();
        //            ftpStream.Close();
        //            response.Close();
        //        }
        //        catch (Exception ex)
        //        {
        //            var s = ex;
        //            //directory already exist I know that is weak but there is no way to check if a folder exist on ftp...
        //            continue;
        //        }
        //    }
        //}
    }
}
