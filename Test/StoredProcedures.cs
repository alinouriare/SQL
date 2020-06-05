using Dapper;
using PartonetMLM.Repository.SP.Metadata;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace PartonetMLM.Repository.SP
{
    public class StoredProcedures
    {
        private readonly string connectionString;
        public StoredProcedures(string _connectionString)
        {
            connectionString = _connectionString;
        }
        public int RegisterNewUser(string username, string password, string ip, string privateKey)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    var result = connection.QueryFirstOrDefault<int>($@"EXEC SpOnlines.RegisterNewUser @username = N'{username}', @password = N'{password}',@ip = N'{ip}',@privateKey = N'{privateKey}'");
                    return result;
                }
            }
            catch (Exception)
            {
                return 0;
            }
        }
        public GetUserByUsernameResult GetUserByUsername(string username)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    var result = connection.QueryFirstOrDefault<GetUserByUsernameResult>($@"EXEC SpOnlines.GetUserByUsername @username = N'{username}'");
                    return result;
                }
            }
            catch (Exception)
            {
                return null;
            }
        }
        public int BlogInsertNewPost(long IdUserCreator, int IdStatusCms, int IdContentType, short IdLanguage, bool showInSite, bool showInClub,
            bool IsSpecial, bool IsOffer, bool EnableComment, DateTime SubmitDate, DateTime? StartPublishDate, DateTime? EndPublishDate,
            string UpTitle, string Title, string AliasName, string SubTitle, string LeadText, string Refrence, string ImageCover,
            string MetaKeywords, string MetaDescription, string MetaRobots, string MetaCanonicalLink, string DisplayType, string ContentText, string IdGroups
            )
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    var query = $@"EXEC SpCms.BlogInsertNewPost 
                                @IdUserCreator = {IdUserCreator},                        
                                @IdStatusCms = {IdStatusCms},                          
                                @IdContentType = {IdContentType},                        
                                @IdLanguage = {IdLanguage},                           
                                 @showInSite = {(showInSite ? "1" : "0")},
                                @showInClub = {(showInClub ? "1" : "0")},
                                @IsSpecial = {(IsSpecial ? "1" : "0")},
                                @IsOffer = {(IsOffer ? "1" : "0")},
                                @EnableComment = {(EnableComment ? "1" : "0")},
                                @SubmitDate = '{SubmitDate}',
                                @StartPublishDate = {(StartPublishDate == null ? "NULL" : "'" + StartPublishDate.ToString() + "'")},
                                @EndPublishDate = {(EndPublishDate == null ? "NULL" : "'" + EndPublishDate.ToString() + "'")},
                                @UpTitle = N'{UpTitle}',
                                @Title = N'{Title}',
                                @AliasName = N'{AliasName}',
                                @SubTitle = N'{SubTitle}',
                                @LeadText = N'{LeadText}',
                                @Refrence = N'{Refrence}',
                                @ImageCover = '{ImageCover}',
                                @MetaKeywords = N'{MetaKeywords}',
                                @MetaDescription = N'{MetaDescription}',
                                @MetaRobots = N'{MetaRobots}',
                                @MetaCanonicalLink = '{MetaCanonicalLink}',
                                @DisplayType = N'{DisplayType}',
                                @ContentText = N'{ContentText}',
                                @IdGroups = N'{IdGroups}'";
                    var result = connection.QueryFirstOrDefault<int>(query);
                    return result;
                }
            }
            catch (Exception e)
            {
                return 0;
            }
        }
        public int BlogUpdateOrInsertPost(long IdContent, long IdUserCreator, int IdStatusCms, int IdContentType, short IdLanguage, bool showInSite, bool showInClub,
                    bool IsSpecial, bool IsOffer, bool EnableComment, DateTime SubmitDate, DateTime? StartPublishDate, DateTime? EndPublishDate,
                    string UpTitle, string Title, string AliasName, string SubTitle, string LeadText, string Refrence, string ImageCover,
                    string MetaKeywords, string MetaDescription, string MetaRobots, string MetaCanonicalLink, string DisplayType, string ContentText, string IdGroups
                    )
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    var query = $@"EXEC SpCms.BlogUpdateOrInsertPost 
                                @IdContent = {IdContent},
                                @IdUserCreator = {IdUserCreator},                        
                                @IdStatusCms = {IdStatusCms},                          
                                @IdContentType = {IdContentType},                        
                                @IdLanguage = {IdLanguage},                           
                                @showInSite = {(showInSite ? "1" : "0")},
                                @showInClub = {(showInClub ? "1" : "0")},
                                @IsSpecial = {(IsSpecial ? "1" : "0")},
                                @IsOffer = {(IsOffer ? "1" : "0")},
                                @EnableComment = {(EnableComment ? "1" : "0")},
                                @SubmitDate = '{SubmitDate.ToString("yyyy-MM-dd HH:MM")}',
                                @StartPublishDate = {(StartPublishDate == null ? "NULL" : "'" + StartPublishDate.GetValueOrDefault().ToString("yyyy-MM-dd HH:MM") + "'")},
                                @EndPublishDate = {(EndPublishDate == null ? "NULL" : "'" + EndPublishDate.GetValueOrDefault().ToString("yyyy-MM-dd HH:MM") + "'")},
                                @UpTitle = N'{UpTitle}',
                                @Title = N'{Title}',
                                @AliasName = N'{AliasName}',
                                @SubTitle = N'{SubTitle}',
                                @LeadText = N'{LeadText}',
                                @Refrence = N'{Refrence}',
                                @ImageCover = '{ImageCover}',
                                @MetaKeywords = N'{MetaKeywords}',
                                @MetaDescription = N'{MetaDescription}',
                                @MetaRobots = N'{MetaRobots}',
                                @MetaCanonicalLink = '{MetaCanonicalLink}',
                                @DisplayType = N'{DisplayType}',
                                @ContentText = N'{ContentText}',
                                @IdGroups = N'{IdGroups}'";
                    var result = connection.QueryFirstOrDefault<int>(query);
                    return result;
                }
            }
            catch (Exception e)
            {
                return 0;
            }
        }
        public List<BlogGetAllContentResult> BlogGetAllContent()
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    var result = connection.Query<BlogGetAllContentResult>($@"EXEC SpCms.BlogGetAllContent");
                    return result.ToList();
                }
            }
            catch (Exception e)
            {
                return null;
            }
        }
        public List<GetAllLanguageResult> GetAllLanguage(bool? isActive)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpGeneral.GetAllLanguage @IsActive = {(isActive == null ? "NULL" : (isActive.GetValueOrDefault() ? "1" : "0"))}";
                    var result = connection.Query<GetAllLanguageResult>(query);
                    return result.ToList();
                }
            }
            catch (Exception)
            {
                return null;
            }
        }
        public BlogGetContentByIdResult BlogGetContentById(long idContent, int idLanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[BlogGetContentById] @IdContent = {idContent},@IdLanguage = {idLanguage}";
                    var result = connection.QueryFirst<BlogGetContentByIdResult>(query);
                    return result;
                }
            }
            catch (Exception)
            {
                return null;
            }
        }
        public int BlogDeleteContentById(long idContent)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpCms.BlogDeleteContentById @IdContent={idContent}";
                    var result = connection.QueryFirst<int>(query);
                    return result;
                }
            }
            catch (Exception)
            {
                return 0;
            }
        }
        public int BlogDeleteImageContentById(long idContent)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpCms.BlogDeleteImageContentById @IdContent={idContent}";
                    var result = connection.QueryFirst<int>(query);
                    return result;
                }
            }
            catch (Exception)
            {
                return 0;
            }
        }
        public int BlogDeleteGroupById(int idGroup)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpCms.BlogDeleteGroupById @IdGroup={idGroup}";
                    var result = connection.QueryFirst<int>(query);
                    return result;
                }
            }
            catch (Exception)
            {
                return 0;
            }
        }
        public int BlogDeleteImageGroupById(int idGroup)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpCms.BlogDeleteImageGroupById @IdGroup={idGroup}";
                    var result = connection.QueryFirst<int>(query);
                    return result;
                }
            }
            catch (Exception)
            {
                return 0;
            }
        }
        public List<GetAllGroupContentResult> GetAllGroupContent(bool? isPublished, int? idLanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpGeneral.GetAllGroupContent @IsPublished = {(isPublished == null ? "NULL" : (isPublished.GetValueOrDefault() ? "1" : "0"))}, @IdLanguage = {(idLanguage == null ? "NULL" : idLanguage.GetValueOrDefault().ToString())}";
                    var result = connection.Query<GetAllGroupContentResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception e)
            {
                return new List<GetAllGroupContentResult>();
            }
        }
        public BlogGetGroupContentByIdAndIdLanguageResult BlogGetGroupContentByIdAndIdLanguage(int idGroup, int idLanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[BlogGetGroupContentByIdAndIdLanguage] @IdGroup = {idGroup}, @IdLanguage = {idLanguage}";
                    var result = connection.QueryFirstOrDefault<BlogGetGroupContentByIdAndIdLanguageResult>(query);
                    return result;
                }
            }
            catch (Exception e)
            {
                return new BlogGetGroupContentByIdAndIdLanguageResult();
            }
        }
        public List<BlogGetAllGroupContentResult> BlogGetAllGroupContent()
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[BlogGetAllGroupContent]";
                    var result = connection.Query<BlogGetAllGroupContentResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception e)
            {
                return new List<BlogGetAllGroupContentResult>();
            }
        }
        public List<BlogGetAllStatusCmsResult> BlogGetAllStatusCms(bool? isPublished, int? idLanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[BlogGetAllStatusCms]";
                    var result = connection.Query<BlogGetAllStatusCmsResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<BlogGetAllStatusCmsResult>();
            }
        }
        public GetDetailContentResult GetDetailContent(long idContent, int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpCms.GetDetailContent @IdContent = {idContent}, @Idlanguage = {idlanguage}";
                    var result = connection.QueryFirst<GetDetailContentResult>(query);
                    return result;
                }
            }
            catch (Exception)
            {
                return new GetDetailContentResult();
            }
        }
        public GetListContentByGroupIdResult GetListContentByGroupId(int idGroup, int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpCms.GetListContentByGroupId @Idgroup = {idGroup}, @Idlanguage = {idlanguage}";
                    var result = connection.QueryFirst<GetListContentByGroupIdResult>(query);
                    return result;
                }
            }
            catch (Exception)
            {
                return new GetListContentByGroupIdResult();
            }
        }
        public List<GetListContentdByTitleResult> GetListContentdByTitle(string title, int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[GetListContentdByTitle] @Idlanguage = {idlanguage}, @Title = N'{title}'";
                    var result = connection.Query<GetListContentdByTitleResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetListContentdByTitleResult>();
            }
        }
        public List<GetListNewsSpecialResult> GetListNewsSpecial(int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[GetListNewsSpecial] @Idlanguage = {idlanguage}";
                    var result = connection.Query<GetListNewsSpecialResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetListNewsSpecialResult>();
            }
        }
        public List<GetListNewContentResult> GetListNewContent(int idGroup, int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[GetListNewContent] @Idlanguage = {idlanguage},  @IdGroup = {idGroup}";
                    var result = connection.Query<GetListNewContentResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetListNewContentResult>();
            }
        }
        public List<GetListCountVisitContentResult> GetListCountVisitContent(int idGroup, int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[GetListCountVisitContent] @Idlanguage = {idlanguage},  @IdGroup = {idGroup}";
                    var result = connection.Query<GetListCountVisitContentResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetListCountVisitContentResult>();
            }
        }
        public List<GetListCommentsResult> GetListComments(long idContent, int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[GetListComments] @Idlanguage = {idlanguage},@IdContent = {idContent}";
                    var result = connection.Query<GetListCommentsResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetListCommentsResult>();
            }
        }
        public List<GetListActiveGroupResult> GetListActiveGroup(int idGroup, int idlanguage)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[GetListActiveGroup] @Idlanguage = {idlanguage},  @IdGroup = {idGroup}";
                    var result = connection.Query<GetListActiveGroupResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetListActiveGroupResult>();
            }
        }
        public List<GetConfigurationResult> GetConfiguration()
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpGeneral].[GetConfiguration]";
                    var result = connection.Query<GetConfigurationResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetConfigurationResult>();
            }
        }
        public int BlogInsertOrUpdateGroup(int? idGroup, int? idLanguage, int? idParent, int idStatus, string idRole, string textIcon,
            string title, string aliasName, string description, string pathImage,
            string metaKeywords, string metaDescription, string metaRobots, string metaCanonical, bool isPublished)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[BlogInsertOrUpdateGroup] @IdGroup = {(idGroup == null ? "NULL" : idGroup.ToString())}, 
                                       @IdLanguage = {(idLanguage == null ? "NULL" : idLanguage.ToString())},
                                       @IdParent = {(idParent == null || idParent <= 0 ? "NULL" : idParent.ToString())},
                                       @IdStatus = {idStatus},
                                       @IdRole = '{idRole}', 
                                       @TextIcon = N'{textIcon}',
                                       @Title = N'{title}',
                                       @AliasName = N'{aliasName}',
                                       @Description = N'{description}',
                                       @PathImage = '{pathImage}',
                                       @MetaKeywords = N'{metaKeywords}',
                                       @MetaDescription = N'{metaDescription}',
                                       @MetaRobots = N'{metaRobots}',
                                       @MetaCanonical = '{metaCanonical}',
                                       @IsPublished = {(isPublished ? 1 : 0)}";
                    var result = connection.QueryFirstOrDefault<int>(query);
                    return result;
                }
            }
            catch (Exception e)
            {
                return 0;
            }
        }
        public List<GetAllStatusCmsResult> GetAllStatusCms()
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC [SpCms].[GetAllStatusCms]";
                    var result = connection.Query<GetAllStatusCmsResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetAllStatusCmsResult>();
            }
        }
        public List<GetAllRoleResult> GetAllRole(bool? isActive)
        {
            try
            {
                using (IDbConnection connection = new SqlConnection(connectionString))
                {
                    string query = $@"EXEC SpGeneral.GetAllRole @IsActive = {(isActive == null ? "NULL" : (isActive.GetValueOrDefault() ? "1" : "0"))}";
                    var result = connection.Query<GetAllRoleResult>(query).ToList();
                    return result;
                }
            }
            catch (Exception)
            {
                return new List<GetAllRoleResult>();
            }
        }
    }
}
