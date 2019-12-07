using System.ComponentModel.DataAnnotations;

namespace Piggyvault.Users.Dto
{
    public class ChangeUserDefaultCurrencyDto
    {
        [Required]
        public string CurrencyCode { get; set; }
    }
}