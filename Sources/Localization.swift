import Foundation

/// Supported application languages.
/// To add a new language:
/// 1. Add a new case to `AppLanguage` (e.g., `case it = "it"`).
/// 2. Add its display name and flag in `displayName` and `flag`.
/// 3. Register its `L10nStrings` translation table in `L10n.tables`.
public enum AppLanguage: String, CaseIterable, Identifiable {
    case en = "en"
    case tr = "tr"
    case de = "de"
    case es = "es"
    case fr = "fr"
    case ru = "ru"
    case ja = "ja"
    case zh = "zh"
    
    public var id: String { rawValue }
    
    public var flag: String {
        switch self {
        case .en: return "🇬🇧"
        case .tr: return "🇹🇷"
        case .de: return "🇩🇪"
        case .es: return "🇪🇸"
        case .fr: return "🇫🇷"
        case .ru: return "🇷🇺"
        case .ja: return "🇯🇵"
        case .zh: return "🇨🇳"
        }
    }
    
    public var displayName: String {
        switch self {
        case .en: return "English"
        case .tr: return "Türkçe"
        case .de: return "Deutsch"
        case .es: return "Español"
        case .fr: return "Français"
        case .ru: return "Русский"
        case .ja: return "日本語"
        case .zh: return "简体中文"
        }
    }
    
    public var badgeLabel: String {
        "\(flag) \(rawValue.uppercased())"
    }
    
    public var menuLabel: String {
        "\(flag)  \(displayName)"
    }
    
    public var strings: L10nStrings {
        L10n.tables[self] ?? L10n.english
    }
}

public struct L10nStrings {
    // Header
    public let appSubtitle: String
    public let chooseFilesButton: String
    public let languageTooltip: String
    
    // Format descriptions
    public let formatWebPDesc: String
    public let formatPNGDesc: String
    public let formatHEICDesc: String
    public let formatAVIFDesc: String
    public let formatTIFFDesc: String
    public let formatPDFDesc: String
    public let formatICNSDesc: String
    
    // Settings
    public let targetFormatLabel: String
    public let qualityLabel: String
    public let autoConvertToggle: String
    public let autoConvertHelp: String
    public let saveLocationLabel: String
    public let saveSameFolder: String
    public let saveCustomFolder: String
    public let chooseFolderButton: String
    public let noFolderSelected: String
    public let quickFolderDesktop: String
    public let quickFolderDownloads: String
    public let quickFolderPictures: String
    public let quickFolderHelp: String
    public let overwriteToggle: String
    public let overwriteHelp: String
    public let deleteOriginalToggle: String
    public let deleteOriginalHelp: String
    
    // Drop Zone & Queue
    public let dropOverlayTitle: String
    public let emptyDropTitle: String
    public let emptyDropSubtitle: String
    public let emptyDropButton: String
    public let miniDropHint: String
    public let miniDropAddButton: String
    public let filesInQueue: (Int) -> String
    
    // Item Row
    public let statusPending: String
    public let statusConverting: String
    public let statusCompleted: String
    public let statusFailed: String
    public let convertSingleHelp: String
    public let revealInFinderHelp: String
    public let retryHelp: (String) -> String
    public let removeFromListHelp: String
    
    // Footer
    public let clearAllButton: String
    public let clearCompletedButton: String
    public let openFolderButton: String
    public let convertingButton: String
    public let convertAllButton: String
    
    // Dialogs & Banners
    public let noSupportedImagesBanner: String
    public let convertedSuccessBanner: (Int) -> String
    public let openPanelPrompt: String
    public let openPanelMessage: String
    public let folderPanelPrompt: String
    public let folderPanelMessage: String
    
    // Engine Errors
    public let errFileNotFound: String
    public let errCannotReadImageSource: String
    public let errCannotCreateImage: String
    public let errCannotCreateDestination: String
    public let errFinalizeFailed: String
    public let errCannotCreateTempFile: String
}

public enum L10n {
    public static let storageKey = "FileConverter.SelectedLanguage"
    
    public static var currentLanguage: AppLanguage {
        get {
            if let saved = UserDefaults.standard.string(forKey: storageKey),
               let lang = AppLanguage(rawValue: saved) {
                return lang
            }
            return .en
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
        }
    }
    
    public static var current: L10nStrings {
        currentLanguage.strings
    }
    
    public static let english = L10nStrings(
        appSubtitle: "Fast Native Image & File Converter for macOS",
        chooseFilesButton: "Choose Files...",
        languageTooltip: "Change Application Language",
        
        formatWebPDesc: "WebP (.webp - Smart Web Optimization)",
        formatPNGDesc: "PNG (.png - Transparency)",
        formatHEICDesc: "HEIC (.heic - Apple High Efficiency)",
        formatAVIFDesc: "AVIF (.avif - Next-Gen Web)",
        formatTIFFDesc: "TIFF (.tiff - Lossless)",
        formatPDFDesc: "PDF (.pdf - Document)",
        formatICNSDesc: "ICNS (.icns - macOS Icon)",
        
        targetFormatLabel: "Target Format:",
        qualityLabel: "Quality:",
        autoConvertToggle: "Auto Convert",
        autoConvertHelp: "Automatically start converting as soon as files are dropped",
        saveLocationLabel: "Save Location:",
        saveSameFolder: "Next to Original File",
        saveCustomFolder: "Custom Folder",
        chooseFolderButton: "Choose Folder...",
        noFolderSelected: "No folder selected",
        quickFolderDesktop: "Desktop",
        quickFolderDownloads: "Downloads",
        quickFolderPictures: "Pictures",
        quickFolderHelp: "Quick folder presets",
        overwriteToggle: "Overwrite existing files",
        overwriteHelp: "If unchecked, existing files are saved as filename (1).jpeg",
        deleteOriginalToggle: "Move original to Trash after conversion",
        deleteOriginalHelp: "Moves the source file to Trash when conversion succeeds",
        
        dropOverlayTitle: "Drop Files Here",
        emptyDropTitle: "Drag & Drop Your Images or Folders Here",
        emptyDropSubtitle: "PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW & more",
        emptyDropButton: "or Choose Files",
        miniDropHint: "Drag more files here or",
        miniDropAddButton: "Add Files",
        filesInQueue: { count in "\(count) file\(count == 1 ? "" : "s") in queue" },
        
        statusPending: "Pending",
        statusConverting: "Converting...",
        statusCompleted: "Completed",
        statusFailed: "Failed",
        convertSingleHelp: "Convert this file",
        revealInFinderHelp: "Reveal in Finder",
        retryHelp: { msg in "Retry: \(msg)" },
        removeFromListHelp: "Remove from list",
        
        clearAllButton: "Clear All",
        clearCompletedButton: "Clear Completed",
        openFolderButton: "Open Folder",
        convertingButton: "Converting...",
        convertAllButton: "Convert All",
        
        noSupportedImagesBanner: "No supported image files found in the dropped items.",
        convertedSuccessBanner: { count in "\(count) file\(count == 1 ? "" : "s") converted successfully." },
        openPanelPrompt: "Add Files",
        openPanelMessage: "Choose image files or folders to convert",
        folderPanelPrompt: "Select Folder",
        folderPanelMessage: "Select the destination folder for converted files",
        
        errFileNotFound: "Source file could not be found.",
        errCannotReadImageSource: "Unsupported image format or corrupted file.",
        errCannotCreateImage: "Could not decode image data.",
        errCannotCreateDestination: "Could not create target output format.",
        errFinalizeFailed: "Failed to write converted file to disk.",
        errCannotCreateTempFile: "Could not create temporary file."
    )
    
    public static let turkish = L10nStrings(
        appSubtitle: "macOS Hızlı Görsel & Dosya Dönüştürücü",
        chooseFilesButton: "Dosya Seç...",
        languageTooltip: "Uygulama Dilini Değiştir",
        
        formatWebPDesc: "WebP (.webp - Akıllı Web Sıkıştırma)",
        formatPNGDesc: "PNG (.png - Şeffaflık Destekli)",
        formatHEICDesc: "HEIC (.heic - Apple Yüksek Verim)",
        formatAVIFDesc: "AVIF (.avif - Yeni Nesil)",
        formatTIFFDesc: "TIFF (.tiff - Kayıpsız)",
        formatPDFDesc: "PDF (.pdf - Belge)",
        formatICNSDesc: "ICNS (.icns - Mac İkonu)",
        
        targetFormatLabel: "Hedef Format:",
        qualityLabel: "Kalite:",
        autoConvertToggle: "Otomatik Çevir",
        autoConvertHelp: "Görselleri sürükleyip bıraktığınız anda dönüştürme başlar",
        saveLocationLabel: "Kayıt Konumu:",
        saveSameFolder: "Orijinal Dosyanın Yanına",
        saveCustomFolder: "Belirlediğim Özel Klasöre",
        chooseFolderButton: "Klasör Seç...",
        noFolderSelected: "Klasör seçilmedi",
        quickFolderDesktop: "Masaüstü",
        quickFolderDownloads: "İndirilenler",
        quickFolderPictures: "Resimler",
        quickFolderHelp: "Hızlı klasör seçimi",
        overwriteToggle: "Mevcut dosyanın üzerine yaz",
        overwriteHelp: "İşaretlenmezse, dosya zaten varsa isim (1).jpeg şeklinde kaydedilir",
        deleteOriginalToggle: "Dönüştürünce orijinali çöp kutusuna at",
        deleteOriginalHelp: "Dönüştürme başarılı olursa kaynak dosyayı Çöp Sepetine taşır",
        
        dropOverlayTitle: "Görselleri Bırakın",
        emptyDropTitle: "Görsellerinizi veya Klasörlerinizi Buraya Sürükleyin",
        emptyDropSubtitle: "PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW ve daha fazlası",
        emptyDropButton: "veya Dosya Seçin",
        miniDropHint: "Daha fazla görsel eklemek için buraya sürükleyin veya",
        miniDropAddButton: "Dosya Ekle",
        filesInQueue: { count in "\(count) dosya sırada" },
        
        statusPending: "Bekliyor",
        statusConverting: "Dönüştürülüyor...",
        statusCompleted: "Tamamlandı",
        statusFailed: "Hata",
        convertSingleHelp: "Bu dosyayı dönüştür",
        revealInFinderHelp: "Finder'da Göster",
        retryHelp: { msg in "Yeniden dene: \(msg)" },
        removeFromListHelp: "Listeden kaldır",
        
        clearAllButton: "Listeyi Temizle",
        clearCompletedButton: "Tamamlananları Temizle",
        openFolderButton: "Klasörü Aç",
        convertingButton: "Dönüştürülüyor...",
        convertAllButton: "Tümünü Dönüştür",
        
        noSupportedImagesBanner: "Sürüklenen dosyalarda desteklenen görsel bulunamadı.",
        convertedSuccessBanner: { count in "\(count) dosya başarıyla dönüştürüldü." },
        openPanelPrompt: "Görselleri Ekle",
        openPanelMessage: "Dönüştürmek istediğiniz görsel dosyalarını veya klasörü seçin",
        folderPanelPrompt: "Klasörü Seç",
        folderPanelMessage: "Dönüştürülen görsellerin kaydedileceği klasörü seçin",
        
        errFileNotFound: "Kaynak dosya bulunamadı.",
        errCannotReadImageSource: "Görsel formatı okunamadı veya dosya bozuk.",
        errCannotCreateImage: "Görsel verisi çözümlenemedi.",
        errCannotCreateDestination: "Hedef dosya biçimi oluşturulamadı.",
        errFinalizeFailed: "Dönüştürülen dosya diske yazılamadı.",
        errCannotCreateTempFile: "Geçici dosya oluşturulamadı."
    )
    
    public static let german = L10nStrings(
        appSubtitle: "Schneller Bild- & Dateikonverter für macOS",
        chooseFilesButton: "Dateien wählen...",
        languageTooltip: "Sprache ändern",
        
        formatWebPDesc: "WebP (.webp - Web-Optimierung)",
        formatPNGDesc: "PNG (.png - Transparenz)",
        formatHEICDesc: "HEIC (.heic - Hohe Effizienz)",
        formatAVIFDesc: "AVIF (.avif - Next-Gen)",
        formatTIFFDesc: "TIFF (.tiff - Verlustfrei)",
        formatPDFDesc: "PDF (.pdf - Dokument)",
        formatICNSDesc: "ICNS (.icns - macOS-Icon)",
        
        targetFormatLabel: "Zielformat:",
        qualityLabel: "Qualität:",
        autoConvertToggle: "Auto-Konvertierung",
        autoConvertHelp: "Konvertierung sofort nach dem Ablegen starten",
        saveLocationLabel: "Speicherort:",
        saveSameFolder: "Neben Originaldatei",
        saveCustomFolder: "Eigener Ordner",
        chooseFolderButton: "Ordner wählen...",
        noFolderSelected: "Kein Ordner ausgewählt",
        quickFolderDesktop: "Schreibtisch",
        quickFolderDownloads: "Downloads",
        quickFolderPictures: "Bilder",
        quickFolderHelp: "Schnellauswahl",
        overwriteToggle: "Vorhandene Dateien überschreiben",
        overwriteHelp: "Wenn deaktiviert, wird als Dateiname (1).jpeg gespeichert",
        deleteOriginalToggle: "Original nach Konvertierung in den Papierkorb",
        deleteOriginalHelp: "Verschiebt die Quelldatei nach erfolgreicher Konvertierung in den Papierkorb",
        
        dropOverlayTitle: "Dateien hier ablegen",
        emptyDropTitle: "Bilder oder Ordner hierher ziehen",
        emptyDropSubtitle: "PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW & mehr",
        emptyDropButton: "oder Dateien wählen",
        miniDropHint: "Weitere Dateien hierher ziehen oder",
        miniDropAddButton: "Dateien hinzufügen",
        filesInQueue: { count in "\(count) Datei\(count == 1 ? "" : "en") in der Warteschlange" },
        
        statusPending: "Wartend",
        statusConverting: "Konvertiere...",
        statusCompleted: "Fertig",
        statusFailed: "Fehler",
        convertSingleHelp: "Diese Datei konvertieren",
        revealInFinderHelp: "Im Finder zeigen",
        retryHelp: { msg in "Erneut versuchen: \(msg)" },
        removeFromListHelp: "Aus Liste entfernen",
        
        clearAllButton: "Liste leeren",
        clearCompletedButton: "Fertige entfernen",
        openFolderButton: "Ordner öffnen",
        convertingButton: "Konvertiere...",
        convertAllButton: "Alle konvertieren",
        
        noSupportedImagesBanner: "Keine unterstützten Bilddateien gefunden.",
        convertedSuccessBanner: { count in "\(count) Datei\(count == 1 ? "" : "en") erfolgreich konvertiert." },
        openPanelPrompt: "Hinzufügen",
        openPanelMessage: "Wählen Sie Bilder oder Ordner zum Konvertieren aus",
        folderPanelPrompt: "Ordner wählen",
        folderPanelMessage: "Zielordner für konvertierte Dateien auswählen",
        
        errFileNotFound: "Quelldatei wurde nicht gefunden.",
        errCannotReadImageSource: "Bildformat wird nicht unterstützt oder Datei beschädigt.",
        errCannotCreateImage: "Bilddaten konnten nicht dekodiert werden.",
        errCannotCreateDestination: "Zielformat konnte nicht erstellt werden.",
        errFinalizeFailed: "Datei konnte nicht auf das Laufwerk geschrieben werden.",
        errCannotCreateTempFile: "Temporäre Datei konnte nicht erstellt werden."
    )
    
    public static let spanish = L10nStrings(
        appSubtitle: "Convertidor rápido de imágenes y archivos para macOS",
        chooseFilesButton: "Elegir archivos...",
        languageTooltip: "Cambiar idioma",
        
        formatWebPDesc: "WebP (.webp - Optimización Web)",
        formatPNGDesc: "PNG (.png - Transparencia)",
        formatHEICDesc: "HEIC (.heic - Alta eficiencia)",
        formatAVIFDesc: "AVIF (.avif - Nueva generación)",
        formatTIFFDesc: "TIFF (.tiff - Sin pérdida)",
        formatPDFDesc: "PDF (.pdf - Documento)",
        formatICNSDesc: "ICNS (.icns - Icono de Mac)",
        
        targetFormatLabel: "Formato:",
        qualityLabel: "Calidad:",
        autoConvertToggle: "Auto convertir",
        autoConvertHelp: "Iniciar la conversión automáticamente al soltar archivos",
        saveLocationLabel: "Guardar en:",
        saveSameFolder: "Junto al archivo original",
        saveCustomFolder: "Carpeta personalizada",
        chooseFolderButton: "Elegir carpeta...",
        noFolderSelected: "Ninguna carpeta seleccionada",
        quickFolderDesktop: "Escritorio",
        quickFolderDownloads: "Descargas",
        quickFolderPictures: "Imágenes",
        quickFolderHelp: "Selección rápida de carpeta",
        overwriteToggle: "Sobrescribir archivos existentes",
        overwriteHelp: "Si no se marca, se guardará como nombre (1).jpeg",
        deleteOriginalToggle: "Mover original a la Papelera al terminar",
        deleteOriginalHelp: "Mueve el archivo original a la Papelera tras convertirlo",
        
        dropOverlayTitle: "Suelta los archivos aquí",
        emptyDropTitle: "Arrastra y suelta tus imágenes o carpetas aquí",
        emptyDropSubtitle: "PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW y más",
        emptyDropButton: "o elegir archivos",
        miniDropHint: "Arrastra más archivos aquí o",
        miniDropAddButton: "Añadir archivos",
        filesInQueue: { count in "\(count) archivo\(count == 1 ? "" : "s") en cola" },
        
        statusPending: "Pendiente",
        statusConverting: "Convirtiendo...",
        statusCompleted: "Completado",
        statusFailed: "Error",
        convertSingleHelp: "Convertir este archivo",
        revealInFinderHelp: "Mostrar en Finder",
        retryHelp: { msg in "Reintentar: \(msg)" },
        removeFromListHelp: "Quitar de la lista",
        
        clearAllButton: "Limpiar todo",
        clearCompletedButton: "Limpiar completados",
        openFolderButton: "Abrir carpeta",
        convertingButton: "Convirtiendo...",
        convertAllButton: "Convertir todo",
        
        noSupportedImagesBanner: "No se encontraron imágenes compatibles.",
        convertedSuccessBanner: { count in "\(count) archivo\(count == 1 ? "" : "s") convertido\(count == 1 ? "" : "s") con éxito." },
        openPanelPrompt: "Añadir",
        openPanelMessage: "Selecciona archivos o carpetas de imágenes para convertir",
        folderPanelPrompt: "Seleccionar carpeta",
        folderPanelMessage: "Selecciona la carpeta de destino",
        
        errFileNotFound: "No se encontró el archivo de origen.",
        errCannotReadImageSource: "Formato no compatible o archivo dañado.",
        errCannotCreateImage: "No se pudieron decodificar los datos de la imagen.",
        errCannotCreateDestination: "No se pudo crear el formato de salida.",
        errFinalizeFailed: "Error al guardar el archivo convertido en el disco.",
        errCannotCreateTempFile: "No se pudo crear el archivo temporal."
    )
    
    public static let french = L10nStrings(
        appSubtitle: "Convertisseur rapide d'images et de fichiers pour macOS",
        chooseFilesButton: "Choisir des fichiers...",
        languageTooltip: "Changer de langue",
        
        formatWebPDesc: "WebP (.webp - Optimisation Web)",
        formatPNGDesc: "PNG (.png - Transparence)",
        formatHEICDesc: "HEIC (.heic - Haute efficacité)",
        formatAVIFDesc: "AVIF (.avif - Nouvelle génération)",
        formatTIFFDesc: "TIFF (.tiff - Sans perte)",
        formatPDFDesc: "PDF (.pdf - Document)",
        formatICNSDesc: "ICNS (.icns - Icône macOS)",
        
        targetFormatLabel: "Format cible :",
        qualityLabel: "Qualité :",
        autoConvertToggle: "Conversion auto",
        autoConvertHelp: "Démarrer automatiquement la conversion dès le dépôt des fichiers",
        saveLocationLabel: "Emplacement :",
        saveSameFolder: "À côté du fichier original",
        saveCustomFolder: "Dossier personnalisé",
        chooseFolderButton: "Choisir un dossier...",
        noFolderSelected: "Aucun dossier sélectionné",
        quickFolderDesktop: "Bureau",
        quickFolderDownloads: "Téléchargements",
        quickFolderPictures: "Images",
        quickFolderHelp: "Accès rapide aux dossiers",
        overwriteToggle: "Écraser les fichiers existants",
        overwriteHelp: "Sinon, enregistré sous nom (1).jpeg",
        deleteOriginalToggle: "Mettre l'original à la corbeille après conversion",
        deleteOriginalHelp: "Déplace le fichier source dans la corbeille une fois converti",
        
        dropOverlayTitle: "Déposez les fichiers ici",
        emptyDropTitle: "Glissez et déposez vos images ou dossiers ici",
        emptyDropSubtitle: "PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW et plus",
        emptyDropButton: "ou choisir des fichiers",
        miniDropHint: "Glissez d'autres fichiers ici ou",
        miniDropAddButton: "Ajouter des fichiers",
        filesInQueue: { count in "\(count) fichier\(count <= 1 ? "" : "s") en attente" },
        
        statusPending: "En attente",
        statusConverting: "Conversion...",
        statusCompleted: "Terminé",
        statusFailed: "Échec",
        convertSingleHelp: "Convertir ce fichier",
        revealInFinderHelp: "Afficher dans le Finder",
        retryHelp: { msg in "Réessayer : \(msg)" },
        removeFromListHelp: "Retirer de la liste",
        
        clearAllButton: "Tout effacer",
        clearCompletedButton: "Effacer terminés",
        openFolderButton: "Ouvrir le dossier",
        convertingButton: "Conversion...",
        convertAllButton: "Tout convertir",
        
        noSupportedImagesBanner: "Aucune image compatible trouvée.",
        convertedSuccessBanner: { count in "\(count) fichier\(count <= 1 ? "" : "s") converti\(count <= 1 ? "" : "s") avec succès." },
        openPanelPrompt: "Ajouter",
        openPanelMessage: "Sélectionnez les images ou dossiers à convertir",
        folderPanelPrompt: "Choisir le dossier",
        folderPanelMessage: "Sélectionnez le dossier de destination",
        
        errFileNotFound: "Fichier source introuvable.",
        errCannotReadImageSource: "Format d'image non reconnu ou fichier corrompu.",
        errCannotCreateImage: "Impossible de décoder l'image.",
        errCannotCreateDestination: "Impossible de créer le format cible.",
        errFinalizeFailed: "Échec de l'écriture du fichier sur le disque.",
        errCannotCreateTempFile: "Impossible de créer le fichier temporaire."
    )
    
    public static let russian = L10nStrings(
        appSubtitle: "Быстрый конвертер изображений и файлов для macOS",
        chooseFilesButton: "Выбрать файлы...",
        languageTooltip: "Изменить язык",
        
        formatWebPDesc: "WebP (.webp - Веб-оптимизация)",
        formatPNGDesc: "PNG (.png - С прозрачностью)",
        formatHEICDesc: "HEIC (.heic - Высокая эффективность)",
        formatAVIFDesc: "AVIF (.avif - Новый формат)",
        formatTIFFDesc: "TIFF (.tiff - Без потерь)",
        formatPDFDesc: "PDF (.pdf - Документ)",
        formatICNSDesc: "ICNS (.icns - Иконка macOS)",
        
        targetFormatLabel: "Формат:",
        qualityLabel: "Качество:",
        autoConvertToggle: "Автоконвертация",
        autoConvertHelp: "Начинать конвертацию сразу после перетаскивания файлов",
        saveLocationLabel: "Сохранить в:",
        saveSameFolder: "Рядом с оригиналом",
        saveCustomFolder: "Выбранная папка",
        chooseFolderButton: "Выбрать папку...",
        noFolderSelected: "Папка не выбрана",
        quickFolderDesktop: "Рабочий стол",
        quickFolderDownloads: "Загрузки",
        quickFolderPictures: "Изображения",
        quickFolderHelp: "Быстрый выбор папки",
        overwriteToggle: "Перезаписывать существующие файлы",
        overwriteHelp: "Если не отмечено, сохраняется как имя (1).jpeg",
        deleteOriginalToggle: "Перемещать оригинал в Корзину после конвертации",
        deleteOriginalHelp: "Перемещает исходный файл в Корзину после успешной конвертации",
        
        dropOverlayTitle: "Перетащите файлы сюда",
        emptyDropTitle: "Перетащите изображения или папки сюда",
        emptyDropSubtitle: "PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW и др.",
        emptyDropButton: "или выберите файлы",
        miniDropHint: "Перетащите ещё файлы сюда или",
        miniDropAddButton: "Добавить файлы",
        filesInQueue: { count in "Файлов в очереди: \(count)" },
        
        statusPending: "Ожидание",
        statusConverting: "Конвертация...",
        statusCompleted: "Готово",
        statusFailed: "Ошибка",
        convertSingleHelp: "Конвертировать этот файл",
        revealInFinderHelp: "Показать в Finder",
        retryHelp: { msg in "Повторить: \(msg)" },
        removeFromListHelp: "Удалить из списка",
        
        clearAllButton: "Очистить всё",
        clearCompletedButton: "Очистить готовые",
        openFolderButton: "Открыть папку",
        convertingButton: "Конвертация...",
        convertAllButton: "Конвертировать всё",
        
        noSupportedImagesBanner: "Поддерживаемые изображения не найдены.",
        convertedSuccessBanner: { count in "Успешно сконвертировано файлов: \(count)." },
        openPanelPrompt: "Добавить",
        openPanelMessage: "Выберите файлы или папки для конвертации",
        folderPanelPrompt: "Выбрать папку",
        folderPanelMessage: "Выберите папку для сохранения файлов",
        
        errFileNotFound: "Исходный файл не найден.",
        errCannotReadImageSource: "Формат не поддерживается или файл повреждён.",
        errCannotCreateImage: "Не удалось декодировать изображение.",
        errCannotCreateDestination: "Не удалось создать целевой формат.",
        errFinalizeFailed: "Не удалось записать файл на диск.",
        errCannotCreateTempFile: "Не удалось создать временный файл."
    )
    
    public static let japanese = L10nStrings(
        appSubtitle: "macOS向け高速ネイティブ画像・ファイル変換ツール",
        chooseFilesButton: "ファイルを選択...",
        languageTooltip: "表示言語を変更",
        
        formatWebPDesc: "WebP (.webp - Web最適化)",
        formatPNGDesc: "PNG (.png - 透過対応)",
        formatHEICDesc: "HEIC (.heic - 高効率)",
        formatAVIFDesc: "AVIF (.avif - 次世代フォーマット)",
        formatTIFFDesc: "TIFF (.tiff - 可逆圧縮)",
        formatPDFDesc: "PDF (.pdf - ドキュメント)",
        formatICNSDesc: "ICNS (.icns - Macアイコン)",
        
        targetFormatLabel: "変換形式:",
        qualityLabel: "画質:",
        autoConvertToggle: "自動変換",
        autoConvertHelp: "ファイルをドロップした瞬間に変換を開始します",
        saveLocationLabel: "保存先:",
        saveSameFolder: "元ファイルと同じ場所",
        saveCustomFolder: "指定フォルダ",
        chooseFolderButton: "フォルダを選択...",
        noFolderSelected: "未選択",
        quickFolderDesktop: "デスクトップ",
        quickFolderDownloads: "ダウンロード",
        quickFolderPictures: "ピクチャ",
        quickFolderHelp: "クイック選択",
        overwriteToggle: "同名ファイルを上書きする",
        overwriteHelp: "オフの場合、ファイル名 (1).jpeg として保存されます",
        deleteOriginalToggle: "変換後に元ファイルをゴミ箱へ移動",
        deleteOriginalHelp: "変換成功後に元ファイルをゴミ箱へ移動します",
        
        dropOverlayTitle: "ここにファイルをドロップ",
        emptyDropTitle: "画像やフォルダをここにドラッグ＆ドロップ",
        emptyDropSubtitle: "PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW などに対応",
        emptyDropButton: "またはファイルを選択",
        miniDropHint: "さらにファイルをドラッグするか",
        miniDropAddButton: "ファイルを追加",
        filesInQueue: { count in "キュー内: \(count) 件" },
        
        statusPending: "待機中",
        statusConverting: "変換中...",
        statusCompleted: "完了",
        statusFailed: "エラー",
        convertSingleHelp: "このファイルを変換",
        revealInFinderHelp: "Finderで表示",
        retryHelp: { msg in "再試行: \(msg)" },
        removeFromListHelp: "リストから削除",
        
        clearAllButton: "すべてクリア",
        clearCompletedButton: "完了済みをクリア",
        openFolderButton: "フォルダを開く",
        convertingButton: "変換中...",
        convertAllButton: "すべて変換",
        
        noSupportedImagesBanner: "対応している画像ファイルが見つかりませんでした。",
        convertedSuccessBanner: { count in "\(count) 件のファイルを変換しました。" },
        openPanelPrompt: "追加",
        openPanelMessage: "変換する画像ファイルまたはフォルダを選択してください",
        folderPanelPrompt: "選択",
        folderPanelMessage: "保存先フォルダを選択してください",
        
        errFileNotFound: "元ファイルが見つかりません。",
        errCannotReadImageSource: "未対応の形式か、ファイルが破損しています。",
        errCannotCreateImage: "画像データを読み込めませんでした。",
        errCannotCreateDestination: "出力形式を作成できませんでした。",
        errFinalizeFailed: "ファイルの書き込みに失敗しました。",
        errCannotCreateTempFile: "一時ファイルを作成できませんでした."
    )
    
    public static let chinese = L10nStrings(
        appSubtitle: "macOS 原生极速图像与文件转换工具",
        chooseFilesButton: "选择文件...",
        languageTooltip: "切换语言",
        
        formatWebPDesc: "WebP (.webp - 网站智能压缩)",
        formatPNGDesc: "PNG (.png - 支持透明)",
        formatHEICDesc: "HEIC (.heic - Apple 高效格式)",
        formatAVIFDesc: "AVIF (.avif - 下一代格式)",
        formatTIFFDesc: "TIFF (.tiff - 无损格式)",
        formatPDFDesc: "PDF (.pdf - 文档)",
        formatICNSDesc: "ICNS (.icns - Mac 图标)",
        
        targetFormatLabel: "目标格式:",
        qualityLabel: "画质:",
        autoConvertToggle: "拖入即转换",
        autoConvertHelp: "拖放文件后立即自动开始转换",
        saveLocationLabel: "保存位置:",
        saveSameFolder: "原文件同目录",
        saveCustomFolder: "自定义文件夹",
        chooseFolderButton: "选择文件夹...",
        noFolderSelected: "未选择文件夹",
        quickFolderDesktop: "桌面",
        quickFolderDownloads: "下载",
        quickFolderPictures: "图片",
        quickFolderHelp: "快速选择目录",
        overwriteToggle: "覆盖同名文件",
        overwriteHelp: "未勾选时将自动重命名为 文件名 (1).jpeg",
        deleteOriginalToggle: "转换完成后将原文件移至废纸篓",
        deleteOriginalHelp: "转换成功后将源文件移入废纸篓",
        
        dropOverlayTitle: "松开以添加文件",
        emptyDropTitle: "将图像或文件夹拖放到此处",
        emptyDropSubtitle: "支持 PNG, JPEG, HEIC, WebP, AVIF, TIFF, GIF, BMP, PDF, RAW 等格式",
        emptyDropButton: "或选择文件",
        miniDropHint: "拖入更多文件或",
        miniDropAddButton: "添加文件",
        filesInQueue: { count in "队列中共 \(count) 个文件" },
        
        statusPending: "等待中",
        statusConverting: "转换中...",
        statusCompleted: "已完成",
        statusFailed: "失败",
        convertSingleHelp: "转换此文件",
        revealInFinderHelp: "在访达中显示",
        retryHelp: { msg in "重试: \(msg)" },
        removeFromListHelp: "从列表中移除",
        
        clearAllButton: "清空全部",
        clearCompletedButton: "清除已完成",
        openFolderButton: "打开文件夹",
        convertingButton: "转换中...",
        convertAllButton: "全部转换",
        
        noSupportedImagesBanner: "拖入的文件中没有受支持的图像格式。",
        convertedSuccessBanner: { count in "成功转换 \(count) 个文件。" },
        openPanelPrompt: "添加文件",
        openPanelMessage: "选择要转换的图像文件或文件夹",
        folderPanelPrompt: "选择文件夹",
        folderPanelMessage: "选择转换后文件的保存目录",
        
        errFileNotFound: "找不到源文件。",
        errCannotReadImageSource: "无法读取图像格式或文件已损坏。",
        errCannotCreateImage: "无法解析图像数据。",
        errCannotCreateDestination: "无法创建目标文件格式。",
        errFinalizeFailed: "无法将转换后的文件写入磁盘。",
        errCannotCreateTempFile: "无法创建临时文件。"
    )
    
    public static let tables: [AppLanguage: L10nStrings] = [
        .en: english,
        .tr: turkish,
        .de: german,
        .es: spanish,
        .fr: french,
        .ru: russian,
        .ja: japanese,
        .zh: chinese
    ]
}

