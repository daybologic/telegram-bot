GRANT USAGE ON *.* TO `telegram_bot`@`%` IDENTIFIED BY PASSWORD '*0000000000000000000000000000000000000000';
GRANT SELECT, INSERT, DELETE ON `telegram_bot`.`user_timeout` TO `telegram_bot`@`%`;
GRANT SELECT ON `telegram_bot`.`audit_event_type` TO `telegram_bot`@`%`;
GRANT SELECT, INSERT, UPDATE ON `telegram_bot`.`user` TO `telegram_bot`@`%`;
GRANT INSERT ON `telegram_bot`.`audit_event` TO `telegram_bot`@`%`;
GRANT SELECT, INSERT, UPDATE ON `telegram_bot`.`user_settings` TO `telegram_bot`@`%`;
GRANT INSERT ON `telegram_bot`.`user_history` TO `telegram_bot`@`%`;
GRANT SELECT, INSERT, DELETE ON `telegram_bot`.`meme` TO `telegram_bot`@`%`;
