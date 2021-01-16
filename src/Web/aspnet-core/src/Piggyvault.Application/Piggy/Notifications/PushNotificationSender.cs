using Abp.Dependency;
using Code.Library.Exceptions;
using Flurl.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Piggyvault.Piggy.Notifications.Dto;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Notifications
{
    public class PushNotificationSender : IPushNotificationSender, ITransientDependency
    {
        private readonly ILogger<PushNotificationSender> _logger;
        private readonly PiggySettings _settings;

        public PushNotificationSender(IOptions<PiggySettings> settings, ILogger<PushNotificationSender> logger)
        {
            _settings = settings.Value;
            _logger = logger;
        }

        public async Task SendAsync(SendPushNotificationJobArgs input)
        {
            if (string.IsNullOrWhiteSpace(_settings.OneSignal.ApiKey) || string.IsNullOrWhiteSpace(_settings.OneSignal.AppId))
            {
                _logger.LogWarning("Required OneSignal settings not found");
                throw new DomainException("Required settings not found");
            }

            var pushData = new
            {
                app_id = _settings.OneSignal.AppId,
                headings = new { en = input.Headings },
                contents = new { en = $"{input.Contents}" },
                data = input.Data,
                filters = new object[] { new { field = "tag", key = "tenancyName", value = input.TenancyName, relation = "=" } },
                android_channel_id = input.ChannelId
            };

            await "https://onesignal.com/api/v1/notifications"
               .WithHeader("Authorization", $"Basic {_settings.OneSignal.ApiKey}")
               .PostJsonAsync(pushData);
        }
    }
}