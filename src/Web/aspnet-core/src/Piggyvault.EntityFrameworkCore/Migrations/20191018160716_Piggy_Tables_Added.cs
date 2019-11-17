using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Piggyvault.Migrations
{
    public partial class Piggy_Tables_Added : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PvAccountType",
                columns: table => new
                {
                    Id = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    Name = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvAccountType", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PvCategory",
                columns: table => new
                {
                    Id = table.Column<Guid>(nullable: false),
                    CreationTime = table.Column<DateTime>(nullable: false),
                    CreatorUserId = table.Column<long>(nullable: true),
                    LastModificationTime = table.Column<DateTime>(nullable: true),
                    LastModifierUserId = table.Column<long>(nullable: true),
                    IsDeleted = table.Column<bool>(nullable: false),
                    DeleterUserId = table.Column<long>(nullable: true),
                    DeletionTime = table.Column<DateTime>(nullable: true),
                    Icon = table.Column<string>(maxLength: 50, nullable: true),
                    IsActive = table.Column<bool>(nullable: false),
                    Name = table.Column<string>(maxLength: 100, nullable: false),
                    TenantId = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvCategory", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PvCurrency",
                columns: table => new
                {
                    Id = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    Code = table.Column<string>(maxLength: 3, nullable: true),
                    DecimalDigits = table.Column<int>(nullable: false),
                    Name = table.Column<string>(maxLength: 50, nullable: true),
                    NamePlural = table.Column<string>(maxLength: 50, nullable: true),
                    Rounding = table.Column<int>(nullable: false),
                    Symbol = table.Column<string>(maxLength: 10, nullable: true),
                    SymbolNative = table.Column<string>(maxLength: 10, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvCurrency", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PvAccount",
                columns: table => new
                {
                    Id = table.Column<Guid>(nullable: false),
                    CreationTime = table.Column<DateTime>(nullable: false),
                    CreatorUserId = table.Column<long>(nullable: true),
                    LastModificationTime = table.Column<DateTime>(nullable: true),
                    LastModifierUserId = table.Column<long>(nullable: true),
                    IsDeleted = table.Column<bool>(nullable: false),
                    DeleterUserId = table.Column<long>(nullable: true),
                    DeletionTime = table.Column<DateTime>(nullable: true),
                    AccountTypeId = table.Column<int>(nullable: false),
                    CurrencyId = table.Column<int>(nullable: false),
                    Name = table.Column<string>(maxLength: 50, nullable: true),
                    TenantId = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvAccount", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PvAccount_PvAccountType_AccountTypeId",
                        column: x => x.AccountTypeId,
                        principalTable: "PvAccountType",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PvAccount_AbpUsers_CreatorUserId",
                        column: x => x.CreatorUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PvAccount_PvCurrency_CurrencyId",
                        column: x => x.CurrencyId,
                        principalTable: "PvCurrency",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PvAccount_AbpUsers_DeleterUserId",
                        column: x => x.DeleterUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PvAccount_AbpUsers_LastModifierUserId",
                        column: x => x.LastModifierUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PvTransaction",
                columns: table => new
                {
                    Id = table.Column<Guid>(nullable: false),
                    CreationTime = table.Column<DateTime>(nullable: false),
                    CreatorUserId = table.Column<long>(nullable: true),
                    LastModificationTime = table.Column<DateTime>(nullable: true),
                    LastModifierUserId = table.Column<long>(nullable: true),
                    IsDeleted = table.Column<bool>(nullable: false),
                    DeleterUserId = table.Column<long>(nullable: true),
                    DeletionTime = table.Column<DateTime>(nullable: true),
                    AccountId = table.Column<Guid>(nullable: false),
                    Amount = table.Column<decimal>(nullable: false),
                    Balance = table.Column<decimal>(nullable: false),
                    CategoryId = table.Column<Guid>(nullable: false),
                    Description = table.Column<string>(maxLength: 1000, nullable: true),
                    IsTransferred = table.Column<bool>(nullable: false),
                    TransactionTime = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvTransaction", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PvTransaction_PvAccount_AccountId",
                        column: x => x.AccountId,
                        principalTable: "PvAccount",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PvTransaction_PvCategory_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "PvCategory",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PvTransaction_AbpUsers_CreatorUserId",
                        column: x => x.CreatorUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PvTransaction_AbpUsers_DeleterUserId",
                        column: x => x.DeleterUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PvTransaction_AbpUsers_LastModifierUserId",
                        column: x => x.LastModifierUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PvTransactionComment",
                columns: table => new
                {
                    Id = table.Column<Guid>(nullable: false),
                    CreationTime = table.Column<DateTime>(nullable: false),
                    CreatorUserId = table.Column<long>(nullable: true),
                    LastModificationTime = table.Column<DateTime>(nullable: true),
                    LastModifierUserId = table.Column<long>(nullable: true),
                    IsDeleted = table.Column<bool>(nullable: false),
                    DeleterUserId = table.Column<long>(nullable: true),
                    DeletionTime = table.Column<DateTime>(nullable: true),
                    Content = table.Column<string>(nullable: true),
                    TransactionId = table.Column<Guid>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvTransactionComment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PvTransactionComment_AbpUsers_CreatorUserId",
                        column: x => x.CreatorUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PvTransactionComment_AbpUsers_DeleterUserId",
                        column: x => x.DeleterUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PvTransactionComment_AbpUsers_LastModifierUserId",
                        column: x => x.LastModifierUserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PvTransactionComment_PvTransaction_TransactionId",
                        column: x => x.TransactionId,
                        principalTable: "PvTransaction",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PvAccount_AccountTypeId",
                table: "PvAccount",
                column: "AccountTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_PvAccount_CreatorUserId",
                table: "PvAccount",
                column: "CreatorUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvAccount_CurrencyId",
                table: "PvAccount",
                column: "CurrencyId");

            migrationBuilder.CreateIndex(
                name: "IX_PvAccount_DeleterUserId",
                table: "PvAccount",
                column: "DeleterUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvAccount_LastModifierUserId",
                table: "PvAccount",
                column: "LastModifierUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransaction_AccountId",
                table: "PvTransaction",
                column: "AccountId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransaction_CategoryId",
                table: "PvTransaction",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransaction_CreatorUserId",
                table: "PvTransaction",
                column: "CreatorUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransaction_DeleterUserId",
                table: "PvTransaction",
                column: "DeleterUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransaction_LastModifierUserId",
                table: "PvTransaction",
                column: "LastModifierUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransactionComment_CreatorUserId",
                table: "PvTransactionComment",
                column: "CreatorUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransactionComment_DeleterUserId",
                table: "PvTransactionComment",
                column: "DeleterUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransactionComment_LastModifierUserId",
                table: "PvTransactionComment",
                column: "LastModifierUserId");

            migrationBuilder.CreateIndex(
                name: "IX_PvTransactionComment_TransactionId",
                table: "PvTransactionComment",
                column: "TransactionId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PvTransactionComment");

            migrationBuilder.DropTable(
                name: "PvTransaction");

            migrationBuilder.DropTable(
                name: "PvAccount");

            migrationBuilder.DropTable(
                name: "PvCategory");

            migrationBuilder.DropTable(
                name: "PvAccountType");

            migrationBuilder.DropTable(
                name: "PvCurrency");
        }
    }
}
