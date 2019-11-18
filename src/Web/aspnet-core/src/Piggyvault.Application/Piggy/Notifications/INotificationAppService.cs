using Code.Library;
using Piggyvault.Notifications.Dto;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Notifications
{
    public interface INotificationAppService
    {
        Task<Result> SendPushNotificationAsync(PushNotificationInput input);
    }
}