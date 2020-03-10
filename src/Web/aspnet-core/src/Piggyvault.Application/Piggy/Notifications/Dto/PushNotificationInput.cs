using System.Collections.Generic;

namespace Piggyvault.Piggy.Notifications.Dto
{
    public class PushNotificationInput
    {
        public string ChannelId { get; set; }
        public string Contents { get; set; }
        public Dictionary<string, string> Data { get; set; }
        public string Headings { get; set; }
    }
}