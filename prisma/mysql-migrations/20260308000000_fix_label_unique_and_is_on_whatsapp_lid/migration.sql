-- CreateIndex: Label unique (labelId, instanceId) for upsert compatibility with PostgreSQL
CREATE UNIQUE INDEX `Label_labelId_instanceId_key` ON `Label`(`labelId`, `instanceId`);

-- AlterTable: Re-add lid column to IsOnWhatsapp (was dropped in Kafka migration, required by app)
ALTER TABLE `IsOnWhatsapp` ADD COLUMN `lid` VARCHAR(100) NULL;
