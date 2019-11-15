using Code.Library;
using Piggyvault.Notifications.Dto;
using System.Threading.Tasks;

namespace Piggyvault.Notifications
{
    public interface INotificationAppService
    {
        Task<Result> SendPushNotificationAsync(PushNotificationInput input);
    }
}