using System.Threading.Tasks;
using Piggyvault.Piggy.Notifications.Dto;

namespace Piggyvault.Piggy.Notifications
{
    public interface IPushNotificationSender
    {
        Task SendAsync(SendPushNotificationJobArgs input);
    }
}