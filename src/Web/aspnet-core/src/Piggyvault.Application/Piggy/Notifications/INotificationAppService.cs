using Code.Library;
using System.Threading.Tasks;
using Piggyvault.Piggy.Notifications.Dto;

namespace Piggyvault.Piggy.Notifications
{
    public interface INotificationAppService
    {
        Task<Result> SendPushNotificationAsync(PushNotificationInput input);
    }
}