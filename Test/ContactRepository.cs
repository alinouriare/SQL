using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.EntityFrameworkCore;
using PartonetMLM.DataLayer.Models;
using PartonetMLM.Repository.Base;
using PartonetMLM.Repository.Metadata.CMS;
using PartonetMLM.Repository.Shared;
using static PartonetMLM.Repository.Metadata.CMS.IContactMetadata;

namespace PartonetMLM.Repository.CMS
{
    public interface IContactRepository
    {
        bool AddContact(ContactMetadata model);
        ContactMetadata GetContactDetails(string trackingCode);
        ContactMetadata GetContactDetailsById(int idContact);
        List<ContactMetadata> GetAllContactMetadata(ContactFilterModel model);
        ResultModel DeleteContact(int idContact);
        bool AddReplayMessage(ReplayContactModel model);
    }
    public class ContactRepository : RepositoryBase, IContactRepository
    {
        public ContactRepository(NEWMLMContext context) : base(context)
        {

        }
        public bool AddContact(ContactMetadata model)
        {
            var contactDbModel = new Contact();

            contactDbModel.CreateDate = DateTime.Now;
            contactDbModel.TrackingCode = model.TrackingCode;
            contactDbModel.IdContactType = model.IdContactType;
            contactDbModel.IdContactStatus = 1;
            contactDbModel.IdContactCategory = model.IdContactCategory;
            contactDbModel.Ip = model.Ip;


            base.Context.Contact.Add(contactDbModel);

            var localizeDbModel = new ContactLanguage()
            {
                IdLanguage = model.ContactLanguagesModel.IdLanguage,
                AttachFile = model.ContactLanguagesModel.AttachFile,
                Email = model.ContactLanguagesModel.Email,
                FullName = model.ContactLanguagesModel.FullName,
                ReplyMessage = model.ContactLanguagesModel.ReplyMessage,
                TextMessage = model.ContactLanguagesModel.TextMessage,
                Subject = model.ContactLanguagesModel.Subject,
                Tel = model.ContactLanguagesModel.Tel

            };

            contactDbModel.ContactLanguage.Add(localizeDbModel);

            return true;
        }

        public ContactMetadata GetContactDetails(string trackingCode)
        {
            var result = (
                from contact in Context.Contact
                join status in Context.ContactStatus on contact.IdContactStatus equals status.Id
                join statusLanguage in Context.ContactStatusLanguage on status.Id equals statusLanguage.IdContactStatus
                join type in Context.ContactType on contact.IdContactType equals type.Id
                join typeLanguage in Context.ContactTypeLanguage on type.Id equals typeLanguage.IdContactType
                join category in Context.ContactCategory on contact.IdContactCategory equals category.Id
                join categoryLanguage in Context.ContactCategoryLanguage on category.Id equals categoryLanguage.IdContactCategory
                join users in Context.UsersSite on contact.IdUsersSite equals users.Id

                where contact.TrackingCode == trackingCode &&

                 statusLanguage.IdLanguage == IdLanguage &&
                 typeLanguage.IdLanguage == IdLanguage &&
                 categoryLanguage.IdLanguage == IdLanguage

                select new ContactMetadata
                {
                    Id = contact.Id,
                    ReplyDate = contact.ReplyDate,
                    CreateDate = contact.CreateDate,
                    Ip = contact.Ip,
                    TrackingCode = contact.TrackingCode,
                    IdUser = contact.IdUsersSite,
                    IdContactCategory = contact.IdContactCategory,
                    IdContactStatus = contact.IdContactStatus,
                    IdContactType = contact.IdContactType,
                    Mobile = users.Mobile,
                    ContactLanguagesModel = contact.ContactLanguage.OrderBy(x => x.IdLanguage == IdLanguage ? 0 : x.IdLanguage == IdDefaultLanguage ? 1 : 2)
                .Select(l => new ContactLanguages
                {
                    FullName = l.FullName,
                    TextMessage = l.TextMessage,
                    Subject = l.Subject,
                    ReplyMessage = l.ReplyMessage,
                    AttachFile = l.AttachFile,
                    Tel = l.Tel,
                    IdLanguage = l.IdLanguage

                }).FirstOrDefault(),
                    ContactType = typeLanguage.Name,
                    ContactCategory = categoryLanguage.Name,
                    ContactStatus = statusLanguage.Name
                }).FirstOrDefault();

            return result;
        }
        public ContactMetadata GetContactDetailsById(int idContact)
        {

            var result = (
                from contact in Context.Contact
                join status in Context.ContactStatus on contact.IdContactStatus equals status.Id
                join statusLanguage in Context.ContactStatusLanguage on status.Id equals statusLanguage.IdContactStatus
                join type in Context.ContactType on contact.IdContactType equals type.Id
                join typeLanguage in Context.ContactTypeLanguage on type.Id equals typeLanguage.IdContactType
                join category in Context.ContactCategory on contact.IdContactCategory equals category.Id
                join categoryLanguage in Context.ContactCategoryLanguage on category.Id equals categoryLanguage.IdContactCategory
                join users in Context.UsersSite on contact.IdUsersSite equals users.Id

                where contact.Id == idContact &&

                 statusLanguage.IdLanguage == IdLanguage &&
                 typeLanguage.IdLanguage == IdLanguage &&
                 categoryLanguage.IdLanguage == IdLanguage

                select new ContactMetadata
                {
                    Id = contact.Id,
                    ReplyDate = contact.ReplyDate,
                    CreateDate = contact.CreateDate,
                    Ip = contact.Ip,
                    TrackingCode = contact.TrackingCode,
                    IdUser = contact.IdUsersSite,
                    IdContactCategory = contact.IdContactCategory,
                    IdContactStatus = contact.IdContactStatus,
                    IdContactType = contact.IdContactType,
                    Mobile = users.Mobile,
                    ContactLanguagesModel = contact.ContactLanguage.OrderBy(x => x.IdLanguage == IdLanguage ? 0 : x.IdLanguage == IdDefaultLanguage ? 1 : 2)
                .Select(l => new ContactLanguages
                {
                    FullName = l.FullName,
                    TextMessage = l.TextMessage,
                    Subject = l.Subject,
                    ReplyMessage = l.ReplyMessage,
                    AttachFile = l.AttachFile,
                    Tel = l.Tel,
                    IdLanguage = l.IdLanguage

                }).FirstOrDefault(),
                    ContactType = typeLanguage.Name,
                    ContactCategory = categoryLanguage.Name,
                    ContactStatus = statusLanguage.Name
                }).FirstOrDefault();

            return result;
        }
        public List<ContactMetadata> GetAllContactMetadata(ContactFilterModel model)
        {
            IQueryable<DataLayer.Models.Contact> query = base.Context.Set<DataLayer.Models.Contact>().AsNoTracking();

            if (!string.IsNullOrEmpty(model.TrackingCode))
            {
                query = query.Where(w => w.TrackingCode == model.TrackingCode);
            }
            if (!string.IsNullOrEmpty(model.Mobile))
            {
                query = query.Where(w => w.IdUsersSiteNavigation.Mobile == model.Mobile);
            }
            if (!string.IsNullOrEmpty(model.Tel))
            {
                query = query.Where(w => w.ContactLanguage.Where(p => p.Tel == model.Tel).Any());
            }
            if (!string.IsNullOrEmpty(model.FullName))
            {
                query = query.Where(w => w.ContactLanguage.Where(p => p.FullName == model.FullName).Any());
            }
            if (!string.IsNullOrEmpty(model.Email))
            {
                query = query.Where(w => w.ContactLanguage.Where(p => p.Email == model.Email).Any());
            }
            if (model.IdLanguage != null)
            {
                query = query.Where(w => w.ContactLanguage.Where(p => p.IdLanguage == model.IdLanguage).Any());
            }
            if (model.FromDate != null)
            {
                query = query.Where(w => w.CreateDate >= model.FromDate);
            }
            if (model.ToDate != null)
            {
                query = query.Where(w => w.CreateDate <= model.ToDate);
            }

            if (model.IdContactCategory != null)
            {
                query = query.Where(w => w.IdContactCategory == model.IdContactCategory);
            }
            if (model.IdContactStatus != null)
            {
                query = query.Where(w => w.IdContactStatus == model.IdContactStatus);
            }

            // var ff = query.ToList();
            return query.Select(s => new ContactMetadata
            {

                Id = s.Id,
                ReplyDate = s.ReplyDate,
                CreateDate = s.CreateDate,
                Ip = s.Ip,
                TrackingCode = s.TrackingCode,
                IdUser = s.IdUsersSite,
                IdContactCategory = s.IdContactCategory,
                IdContactStatus = s.IdContactStatus,
                IdContactType = s.IdContactType,
                IdAgentReplyer = s.IdAgentReplyer,
                ContactLanguagesModel = s.ContactLanguage.OrderBy(x => x.IdLanguage == IdLanguage ? 0 : x.IdLanguage == IdDefaultLanguage ? 1 : 2)
                .Select(l => new ContactLanguages
                {
                    FullName = l.FullName,
                    TextMessage = l.TextMessage,
                    Subject = l.Subject,
                    ReplyMessage = l.ReplyMessage,
                    AttachFile = l.AttachFile,
                    Tel = l.Tel,
                    IdLanguage = l.IdLanguage,
                    Email = l.Email,
                    LanguageName = Context.Language.AsNoTracking().FirstOrDefault(f => f.Id == l.IdLanguage).Name

                }).FirstOrDefault(),

                Mobile =s.IdUsersSiteNavigation.Mobile,

                ContactType = Context.ContactTypeLanguage.AsNoTracking().Where(w => w.IdContactType == s.IdContactType)
               .OrderBy(x => x.IdLanguage == IdLanguage ? 0 : x.IdLanguage == IdDefaultLanguage ? 1 : 2)
               .FirstOrDefault().Name,

                ContactCategory = Context.ContactCategoryLanguage.AsNoTracking().Where(w => w.IdContactCategory == s.IdContactCategory)
               .OrderBy(x => x.IdLanguage == IdLanguage ? 0 : x.IdLanguage == IdDefaultLanguage ? 1 : 2)
               .FirstOrDefault().Name,

                ContactStatus = Context.ContactStatusLanguage.AsNoTracking().Where(w => w.IdContactStatus == s.IdContactStatus)
               .OrderBy(x => x.IdLanguage == IdLanguage ? 0 : x.IdLanguage == IdDefaultLanguage ? 1 : 2)
               .FirstOrDefault().Name,

            }).ToList();

        }
        public ResultModel DeleteContact(int idContact)
        {
            //Todo set roll back 
            try
            {
                var contactDbModel = Context.Contact.FirstOrDefault(x => x.Id == idContact);
                if (contactDbModel == null)
                {
                    return new ResultModel() { HasError = true };
                }

                base.Context.Contact.Remove(contactDbModel);

                var localizeDbModel = Context.ContactLanguage.Where(x => x.IdContact == idContact).ToList();
                if (localizeDbModel == null)
                {
                    return new ResultModel() { HasError = true };
                }
                base.Context.ContactLanguage.RemoveRange(localizeDbModel);
                base.Context.SaveChanges();
                return new ResultModel() { HasError = false };
            }
            catch (Exception ex)
            {
                return new ResultModel() { HasError = true, Message = ex?.InnerException?.Message };
            }
        }
        public bool AddReplayMessage(ReplayContactModel model)
        {
            var contactDbModel = base.Context.Contact.Include(i=>i.ContactLanguage).FirstOrDefault(f => f.Id == model.IdContact);

            contactDbModel.IdAgentReplyer = model.IdAgentReplyer;
            contactDbModel.IdContactCategory = model.IdContactCategory;
            contactDbModel.ReplyDate = DateTime.Now;
            contactDbModel.IdContactStatus = model.IdContactStatus;

            ContactLanguage localizeDbModel = null;
            if (contactDbModel.ContactLanguage != null)
            {
                localizeDbModel = contactDbModel.ContactLanguage.FirstOrDefault(x => x.IdLanguage == model.IdLanguage);
            }
            //if (localizeDbModel == null)
            //{
            //    localizeDbModel = new ContactLanguage();
            //    localizeDbModel.IdLanguage = model.IdLanguage;
            //    contactDbModel.ContactLanguage.Add(localizeDbModel);
            //}
            localizeDbModel.ReplyMessage = model.ReplayMessage;


            base.Context.SaveChanges();
            return true;
        }


    }
}

