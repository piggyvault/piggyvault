using Abp.Authorization;
using Code.Library;
using Piggyvault.Notifications.Dto;
using Piggyvault.Sessions;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Piggyvault.Notifications
{
    [AbpAuthorize]
    public class NotificationAppService : PiggyvaultAppServiceBase, INotificationAppService
    {
        private readonly ISessionAppService _sessionAppService;

        public NotificationAppService(ISessionAppService sessionAppService)
        {
            _sessionAppService = sessionAppService;
        }

        public async Task<Result> SendPushNotificationAsync(PushNotificationInput input)
        {
            // TODO: Outdated
            return Result.Ok();

            //var currentUser = await _sessionAppService.GetCurrentLoginInformations();

            //if (currentUser != null)
            //{
            //    var request = WebRequest.Create("https://onesignal.com/api/v1/notifications") as HttpWebRequest;

            //    if (request != null)
            //    {
            //        request.KeepAlive = true;
            //        request.Method = "POST";
            //        request.ContentType = "application/json; charset=utf-8";

            //        request.Headers.Add("authorization", "Basic TODO");

            //        var serializer = new JavaScriptSerializer();
            //        var obj = new
            //        {
            //            app_id = "TODO",
            //            headings = new { en = input.Headings },
            //            contents = new { en = $"{input.Contents}" },
            //            data = input.Data,
            //            filters = new object[] { new { field = "tag", key = "tenancyName", value = currentUser.Tenant.TenancyName.Trim().ToLowerInvariant(), relation = "=" } }
            //        };

            //        var param = serializer.Serialize(obj);
            //        byte[] byteArray = Encoding.UTF8.GetBytes(param);

            //        string responseContent = null;

            //        try
            //        {
            //            using (var writer = request.GetRequestStream())
            //            {
            //                writer.Write(byteArray, 0, byteArray.Length);
            //            }

            //            using (var response = request.GetResponse() as HttpWebResponse)
            //            {
            //                using (var reader = new StreamReader(response.GetResponseStream()))
            //                {
            //                    responseContent = reader.ReadToEnd();
            //                    return Result.Ok();
            //                }
            //            }
            //        }
            //        catch (WebException ex)
            //        {
            //            Logger.Error("Create notification failed", ex);
            //            return Result.Fail(ex.Message);
            //        }
            //    }
            //}

            //return Result.Fail("Something went wrong. Failed to sent push notification");
        }
    }
}