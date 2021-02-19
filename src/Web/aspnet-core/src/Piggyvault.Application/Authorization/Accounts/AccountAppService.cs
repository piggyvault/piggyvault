using Abp.Configuration;
using Abp.Extensions;
using Abp.UI;
using Abp.Zero.Configuration;
using Piggyvault.Authorization.Accounts.Dto;
using Piggyvault.Authorization.Users;
using System.Threading.Tasks;

namespace Piggyvault.Authorization.Accounts
{
    public class AccountAppService : PiggyvaultAppServiceBase, IAccountAppService
    {
        // from: http://regexlib.com/REDetails.aspx?regexp_id=1923
        public const string PasswordRegex = "(?=^.{8,}$)(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\\s)[0-9a-zA-Z!@#$%^&*()]*$";

        private readonly UserRegistrationManager _userRegistrationManager;

        public AccountAppService(
            UserRegistrationManager userRegistrationManager)
        {
            _userRegistrationManager = userRegistrationManager;
        }

        public async Task<IsTenantAvailableOutput> IsTenantAvailable(IsTenantAvailableInput input)
        {
            var tenant = await TenantManager.FindByTenancyNameAsync(input.TenancyName);
            if (tenant == null)
            {
                return new IsTenantAvailableOutput(TenantAvailabilityState.NotFound);
            }

            if (!tenant.IsActive)
            {
                return new IsTenantAvailableOutput(TenantAvailabilityState.InActive);
            }

            return new IsTenantAvailableOutput(TenantAvailabilityState.Available, tenant.Id);
        }

        public async Task SendPasswordResetCode(SendPasswordResetCodeInput input)
        {
            var user = await UserManager.FindByEmailAsync(input.EmailAddress);

            if (user == null)
            {
                throw new UserFriendlyException("User not found!");
            }

            user.SetNewPasswordResetCode();

            //Send an email to user with the below password reset code
            /* Uri.EscapeDataString(user.PasswordResetCode) */
        }

        public async Task<RegisterOutput> Register(RegisterInput input)
        {
            var user = await _userRegistrationManager.RegisterAsync(
                input.Name,
                input.Surname,
                input.EmailAddress,
                input.UserName,
                input.Password,
                true // Assumed email address is always confirmed. Change this if you want to implement email confirmation.
            );

            var isEmailConfirmationRequiredForLogin = await SettingManager.GetSettingValueAsync<bool>(AbpZeroSettingNames.UserManagement.IsEmailConfirmationRequiredForLogin);

            return new RegisterOutput
            {
                CanLogin = user.IsActive && (user.IsEmailConfirmed || !isEmailConfirmationRequiredForLogin)
            };
        }

        public async Task<bool> ResetPassword(ResetPasswordInput input)
        {
            var user = await UserManager.GetUserByIdAsync(input.UserId);

            if (user == null || user.PasswordResetCode.IsNullOrEmpty() || user.PasswordResetCode != input.ResetCode)
            {
                throw new UserFriendlyException("Invalid password reset code");
            }

            await UserManager.InitializeOptionsAsync(AbpSession.TenantId);
            CheckErrors(await UserManager.ChangePasswordAsync(user, input.Password));

            user.PasswordResetCode = null;
            user.IsEmailConfirmed = true;

            await UserManager.UpdateAsync(user);

            return true;
        }
    }
}