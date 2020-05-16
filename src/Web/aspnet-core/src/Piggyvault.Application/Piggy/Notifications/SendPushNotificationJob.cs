using Abp.BackgroundJobs;
using Abp.Dependency;
using Abp.Threading;
using Microsoft.Extensions.Logging;
using Piggyvault.Piggy.Notifications.Dto;

namespace Piggyvault.Piggy.Notifications
{
    public class SendPushNotificationJob : BackgroundJob<SendPushNotificationJobArgs>, ITransientDependency
    {
        private readonly ILogger<SendPushNotificationJob> _logger;
        private readonly PushNotificationSender _notificationSender;

        public SendPushNotificationJob(PushNotificationSender notificationSender, ILogger<SendPushNotificationJob> logger)
        {
            _notificationSender = notificationSender;
            _logger = logger;
        }

        public override void Execute(SendPushNotificationJobArgs args)
        {
            _logger.LogDebug("----- Sending push notification");
            AsyncHelper.RunSync(() => _notificationSender.SendAsync(args));
        }
    }
}