using Abp.Authorization;
using Code.Library;
using Flurl.Http;
using Piggyvault.Sessions;
using System;
using System.Threading.Tasks;
using Piggyvault.Piggy.Notifications.Dto;

namespace Piggyvault.Piggy.Notifications
{
    [AbpAuthorize]
    public class NotificationAppService : PiggyvaultAppServiceBase, INotificationAppService
    {
        private readonly ISessionAppService _sessionAppService;
        private readonly PiggySettings _settings;

        public NotificationAppService(ISessionAppService sessionAppService, PiggySettings settings)
        {
            _sessionAppService = sessionAppService;
            _settings = settings;
        }

        public async Task<Result> SendPushNotificationAsync(PushNotificationInput input)
        {
            if (string.IsNullOrWhiteSpace(_settings.OneSignal.ApiKey) || string.IsNullOrWhiteSpace(_settings.OneSignal.AppId))
            {
                return Result.Fail("Required settings not found");
            }

            try
            {
                var currentUser = await _sessionAppService.GetCurrentLoginInformations();

                if (currentUser != null)
                {
                    var pushData = new
                    {
                        app_id = _settings.OneSignal.AppId,
                        headings = new { en = input.Headings },
                        contents = new { en = $"{input.Contents}" },
                        data = input.Data,
                        filters = new object[] { new { field = "tag", key = "tenancyName", value = currentUser.Tenant.TenancyName.Trim().ToLowerInvariant(), relation = "=" } },
                        android_channel_id = input.ChannelId
                    };

                    var result = await "https://onesignal.com/api/v1/notifications"
                        .WithHeader("Authorization", $"Basic {_settings.OneSignal.ApiKey}")
                        .PostJsonAsync(pushData);

                    if (result.StatusCode == System.Net.HttpStatusCode.OK)
                    {
                        return Result.Ok();
                    }
                }
            }
            catch (Exception ex)
            {
                // TODO: log
            }

            return Result.Fail("Something went wrong. Failed to sent push notification");
        }
    }
}