using Abp.BackgroundJobs;
using Abp.Dependency;
using Abp.Threading;
using Piggyvault.Piggy.Notifications.Dto;

namespace Piggyvault.Piggy.Notifications
{
    public class SendPushNotificationJob : BackgroundJob<SendPushNotificationJobArgs>, ITransientDependency
    {
        private readonly INotificationAppService _notificationService;

        public SendPushNotificationJob(INotificationAppService notificationService)
        {
            _notificationService = notificationService;
        }

        public override void Execute(SendPushNotificationJobArgs args)
        {
            AsyncHelper.RunSync(() => _notificationService.SendPushNotificationAsync(args));
        }
    }
}