public function auth()
    {
        if (preg_match('~^/id$~', $this->input['message'])) {
            return;
        }
        $file = __DIR__ . '/config.php';
        require $file;
        if (empty($c['admin'])) {
            $c['admin'] = [$this->input['from']];
            file_put_contents($file, "<?php\n\n\$c = " . var_export($c, true) . ";\n");
        } elseif (!is_array($c['admin'])) {
            $c['admin'] = [$c['admin']];
            file_put_contents($file, "<?php\n\n\$c = " . var_export($c, true) . ";\n");
        } elseif (!in_array($this->input['from'], $c['admin'])) {
            $this->verifyUser();
            exit;
        }
    }

    public function verifyUser()
    {
        $clients = $this->getXray()['inbounds'][0]['settings']['clients'] ?? [];

        $foundIndexes = [];
        foreach ($clients as $i => $user) {
            if (
                isset($user['email']) &&
                preg_match('/\[tg_(\d+)]/i', $user['email'], $m) &&
                (string)$m[1] === (string)$this->input['from']
            ) {
                $foundIndexes[] = $i;
            }
        }

        if (empty($foundIndexes)) {
            return;
        }

        $pac    = $this->getPacConf();
        $domain = $this->getDomain($pac['transport'] != 'Reality');
        $scheme = empty($this->nginxGetTypeCert()) ? 'http' : 'https';
        $hash   = $this->getHashBot();

        $messageParts = [];

        foreach ($foundIndexes as $index) {
            $c = $clients[$index];
            $email = $c['email'];

            $si = "{$scheme}://{$domain}/pac{$hash}/" . base64_encode(serialize([
                'h' => $hash,
                't' => 'si',
                's' => $c['id'],
            ]));

            $emailLower = strtolower($email);
            $isOpenWrt = str_contains($emailLower, 'openwrt');
            $isWindows = str_contains($emailLower, 'windows');
            $isTablet = str_contains($emailLower, 'tablet');

            $textParts = [];

            $textParts[] = "🧾 <b>Конфиг для:</b> <code>" . preg_replace('/^\[tg_\d+]\_?/', '', $email) . "</code>";

            if ($isOpenWrt) {
                $textParts[] = "📡 <b>Роутер (OpenWRT)</b>\n"
                . "⚠️ Только для OpenWRT.\n"
                . "1. Установите интерфейс: <a href='https://github.com/ang3el7z/luci-app-singbox-ui (GitHub)</a>\n"
                . "2. Используйте следующий конфиг-сервер:\n"
                . "<pre><code>{$si}</code></pre>\n"
                . "✅ Подходит для ручного импорта.";
            } elseif ($isWindows) {
                $textParts[] = "🖥 <b>Windows</b>\n"
                . "⚠️ Только для Windows 10/11.\n"
                . "1. Скачайте клиент: <a href='{$scheme}://{$domain}/pac{$hash}?t=si&r=w&s={$c['id']}'>sing-box для Windows</a>\n"
                . "2. Распакуйте, например, в <code>C:\\serviceBot</code> ⚠️ <i>Имя пути только на англ.!</i>\n"
                . "3. Запустите <code>install</code>, затем <code>start</code>.\n"
                . "4. Проверка подключения: выполните <code>status</code>\n"
                . "✅ Работает автоматически, включая при перезагрузке.";
            } elseif ($isTablet) {
                $textParts[] = "📱 <b>Планшет (Android / iOS)</b>\n"
                . "⚠️ Только для Android / iOS.\n"
                . "1. Установите приложение <b>sing-box</b>:\n"
                . "• <a href='https://play.google.com/store/apps/details?id=io.nekohasekai.sfa&hl=ru&pli=1'>Android (Play Store)</a>\n"
                . "• <a href='https://apps.apple.com/ru/app/sing-box-vt/id6673731168?l=en-ru'>iPhone (App Store)</a>\n"
                . "2. Перейдите по ссылке: <a href='{$scheme}://{$domain}/pac{$hash}?t=si&r=si&s={$c['id']}#{$email}'>import://sing-box</a>\n"
                . "3. Нажмите <b>Import</b> → <b>Create</b>.\n"
                . "4. Перейдите в <b>Dashboard</b> и нажмите <b>Start</b>.\n"
                . "✅ Всё готово для использования.";
            } else {
                $textParts[] = "📱 <b>Телефон (Android / iOS)</b>\n"
                . "⚠️ Только для Android / iOS.\n"
                . "1. Установите приложение <b>sing-box</b>:\n"
                . "• <a href='https://play.google.com/store/apps/details?id=io.nekohasekai.sfa&hl=ru&pli=1'>Android (Play Store)</a>\n"
                . "• <a href='https://apps.apple.com/ru/app/sing-box-vt/id6673731168?l=en-ru'>iPhone (App Store)</a>\n"
                . "2. Перейдите по ссылке: <a href='{$scheme}://{$domain}/pac{$hash}?t=si&r=si&s={$c['id']}#{$email}'>import://sing-box</a>\n"
                . "3. Нажмите <b>Import</b> → <b>Create</b>.\n"
                . "4. Перейдите в <b>Dashboard</b> и нажмите <b>Start</b>.\n"
                . "✅ Всё готово для использования.";
            }

            $textParts[] = "🔒 <b>Ограничения</b>\n"
                . "• 1 конфиг = 1 устройство\n"
                . "• Попытка поделиться конфигом с посторонними человеком ➜ <b>бан навсегда</b>\n"
                . "• Нельзя использовать одновременно на несколько устройств";

            $textParts[] = "🆘 <b>Поддержка:</b> @bot"; //Вставить если нужно

            $messageParts[] = implode("\n\n", $textParts);
        }

        $messageParts[] = implode("\n\n", [
            "<b>⚠️ Перед использованием обязательно нажмите кнопку ниже для получения актуальной конфигурации ⚠️</b>",
        ]);

        $data[] = [
            [
                'text'          => "🔄 Обновить",
                'callback_data' => "/menu",
            ],
        ];

        $this->send(
            $this->input['chat'],
            implode("\n\n———————————————\n\n", $messageParts),
            $this->input['message_id'],
            $data,
            false,
            'HTML',
            false,
            true
        );
    }
