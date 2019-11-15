using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Notifications.Dto
{
    public class PushNotificationInput
    {
        public string Contents { get; set; }
        public Dictionary<string, string> Data { get; set; }
        public string Headings { get; set; }
    }
}