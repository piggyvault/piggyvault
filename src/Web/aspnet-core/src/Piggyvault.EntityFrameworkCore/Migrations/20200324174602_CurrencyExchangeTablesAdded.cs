using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Piggyvault.Migrations
{
    public partial class CurrencyExchangeTablesAdded : Migration
    {
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PvCurrencyExchangeRate");

            migrationBuilder.DropTable(
                name: "PvMonitoredExchangeRate");

            migrationBuilder.DropTable(
                name: "PvCurrencyExchangePreset");
        }

        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PvCurrencyExchangePreset",
                columns: table => new
                {
                    Id = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreationTime = table.Column<DateTime>(nullable: false),
                    FromCurrencyId = table.Column<int>(nullable: false),
                    ToCurrencyId = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvCurrencyExchangePreset", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PvCurrencyExchangePreset_PvCurrency_FromCurrencyId",
                        column: x => x.FromCurrencyId,
                        principalTable: "PvCurrency",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_PvCurrencyExchangePreset_PvCurrency_ToCurrencyId",
                        column: x => x.ToCurrencyId,
                        principalTable: "PvCurrency",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateTable(
                name: "PvCurrencyExchangeRate",
                columns: table => new
                {
                    Id = table.Column<Guid>(nullable: false),
                    CreationTime = table.Column<DateTime>(nullable: false),
                    CurrencyExchangePresetId = table.Column<int>(nullable: false),
                    Rate = table.Column<decimal>(type: "decimal(18, 6)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvCurrencyExchangeRate", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PvCurrencyExchangeRate_PvCurrencyExchangePreset_CurrencyExchangePresetId",
                        column: x => x.CurrencyExchangePresetId,
                        principalTable: "PvCurrencyExchangePreset",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PvMonitoredExchangeRate",
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
                    CurrencyExchangePresetId = table.Column<int>(nullable: false),
                    IsFeatured = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PvMonitoredExchangeRate", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PvMonitoredExchangeRate_PvCurrencyExchangePreset_CurrencyExchangePresetId",
                        column: x => x.CurrencyExchangePresetId,
                        principalTable: "PvCurrencyExchangePreset",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PvCurrencyExchangePreset_FromCurrencyId",
                table: "PvCurrencyExchangePreset",
                column: "FromCurrencyId");

            migrationBuilder.CreateIndex(
                name: "IX_PvCurrencyExchangePreset_ToCurrencyId",
                table: "PvCurrencyExchangePreset",
                column: "ToCurrencyId");

            migrationBuilder.CreateIndex(
                name: "IX_PvCurrencyExchangeRate_CurrencyExchangePresetId",
                table: "PvCurrencyExchangeRate",
                column: "CurrencyExchangePresetId");

            migrationBuilder.CreateIndex(
                name: "IX_PvMonitoredExchangeRate_CurrencyExchangePresetId",
                table: "PvMonitoredExchangeRate",
                column: "CurrencyExchangePresetId");
        }
    }
}