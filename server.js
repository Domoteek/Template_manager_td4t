const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = 3000;
const WORK_DIR = __dirname; // Current directory

const MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.bmp': 'image/bmp',
    '.svg': 'image/svg+xml'
};

const CATEGORY_MAPPINGS = {
    'ABA': 'ABATTAGE',
    'AMO': 'AMOUR',
    'BAR': 'BARBECUE',
    'BOU': 'BOUCHERIE',
    'COM': 'COMPOSITION',
    'FET': 'FÊTES',
    'FRA': 'FRAICHE DECOUPE',
    'M': 'MAISON',
    'MAI': 'MAISON',
    'MAR': 'MAREE',
    'ORI': 'ORIGINE',
    'PIZ': 'PIZZA',
    'PRE': 'PREPARATION',
    'PRI': 'PRIX',
    'PR': 'PROMO',
    'PRO': 'PROMO',
    'VIA': 'VIA'
};

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const parsedUrl = new URL(req.url, `http://${req.headers.host}`);

    // API Endpoints
    if (parsedUrl.pathname === '/api/save-template' && req.method === 'POST') {
        handleSaveTemplate(req, res);
        return;
    }

    if (parsedUrl.pathname === '/api/delete-template' && req.method === 'POST') {
        handleDeleteTemplate(req, res);
        return;
    }

    if (parsedUrl.pathname === '/api/list-templates' && req.method === 'GET') {
        handleListTemplates(req, res);
        return;
    }

    if (parsedUrl.pathname === '/prepare-usb' && req.method === 'POST') {
        handlePrepareUsb(req, res);
        return;
    }

    if (parsedUrl.pathname === '/api/generate-manual' && req.method === 'POST') {
        handleGenerateManual(req, res);
        return;
    }

    // Static File Serving
    let filePath = path.join(WORK_DIR, parsedUrl.pathname === '/' ? 'template_manager.html' : parsedUrl.pathname);

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, content) => {
        if (err) {
            if (err.code === 'ENOENT') {
                res.writeHead(404);
                res.end('File not found');
            } else {
                res.writeHead(500);
                res.end(`Server Error: ${err.code}`);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        }
    });
});

function handleListTemplates(req, res) {
    try {
        const allFiles = fs.readdirSync(WORK_DIR);
        const bmpFiles = allFiles
            .filter(file => file.toLowerCase().endsWith('.bmp'))
            // Exclusions système ET 'USB'
            .filter(file => !file.startsWith('Logo_GM') && !file.startsWith('.') && !file.toUpperCase().startsWith('USB'));

        const metadata = extractMetadataFromBas();

        const templates = bmpFiles.map(file => {
            const code = path.parse(file).name.toUpperCase();

            // Special handling for 40x27 templates
            const code40x27 = ['1', '2', '3', '4', '5', '10'];
            let category;

            if (code40x27.includes(code)) {
                category = '40x27'; // Or '40x27 BLANCHE' if preferred, keeping it short for UI
            } else {
                const prefix = code.replace(/[0-9]/g, '');
                category = CATEGORY_MAPPINGS[prefix] || prefix;
            }

            const meta = metadata[code] || {};

            return {
                code: code,
                // Nom par défaut, le frontend pourra enrichir
                name: `${category} ${code}`,
                category: category,
                imageData: file, // Chemin relatif
                positionX: meta.positionX !== undefined ? meta.positionX : 22,
                positionY: meta.positionY !== undefined ? meta.positionY : 22,
                cropTop: meta.cropTop !== undefined ? meta.cropTop : 0,
                isExisting: true
            };
        });

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(templates));
    } catch (e) {
        console.error(e);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: "Erreur lors du scan des templates" }));
    }
}

function handleSaveTemplate(req, res) {
    let body = '';
    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        try {
            const data = JSON.parse(body);
            processTemplate(data, res);
        } catch (e) {
            console.error(e);
            res.writeHead(400, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: "Invalid JSON" }));
        }
    });
}

function handleDeleteTemplate(req, res) {
    let body = '';
    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        try {
            const data = JSON.parse(body);
            const { code } = data;
            const lowerCode = code.toLowerCase();

            // 1. Delete Image
            const imagePath = path.join(WORK_DIR, `${lowerCode}.bmp`);
            if (fs.existsSync(imagePath)) {
                fs.unlinkSync(imagePath);
                console.log(`Deleted image: ${imagePath}`);
            }

            // 2. Remove from Prog_Gestmag.BAS
            cleanupProgGestmag(code);

            // 3. Remove from AUTO.BAS
            cleanupAutoBas(lowerCode + '.bmp');

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: true, message: `Template ${code} deleted completely.` }));

        } catch (e) {
            console.error(e);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: "Server Error during deletion" }));
        }
    });
}

function processTemplate(data, res) {
    const { code, name, imageData, positionX, positionY, cropTop } = data;
    const lowerCode = code.toLowerCase();

    // 1. Save Image
    if (imageData && imageData.startsWith('data:image')) {
        const base64Data = imageData.replace(/^data:image\/\w+;base64,/, "");
        const buffer = Buffer.from(base64Data, 'base64');
        const imagePath = path.join(WORK_DIR, `${lowerCode}.bmp`);

        fs.writeFileSync(imagePath, buffer);
        console.log(`Saved image: ${imagePath}`);
    }

    // 2. Prepare Internal Content (No external files)
    const cropTopValue = cropTop || 0;
    const iniBlock = `DOWNLOAD F,"${code}.INI"
REM - CROPTOP = ${cropTopValue}
EOP`;

    const basBlock = `DOWNLOAD F,"${code}.BAS"
	qTphDpi$ = GETSETTING$("SYSTEM","INFORMATION","DPI")
	IF qTphDpi$ = "203" THEN
        SIZE 46 mm, 46 mm
        DIRECTION 1
        CLS
        PUTBMP ${positionX !== undefined ? positionX : 22}, ${positionY !== undefined ? positionY : 22}, "${lowerCode}.bmp", 1
        PRINT VAL(qQty$)
    ENDIF
EOP`;

    // 3. Update Prog_Gestmag.BAS with both blocks
    updateProgGestmag(code, basBlock, iniBlock);

    // 4. Update AUTO.BAS (Ensure .bmp extension)
    updateAutoBas(lowerCode + '.bmp');

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: true, message: `Template ${code} integrated successfully.` }));
}

function updateProgGestmag(code, basBlock, iniBlock) {
    const progPath = path.join(WORK_DIR, 'Prog_Gestmag.BAS');
    if (!fs.existsSync(progPath)) return;

    let content = fs.readFileSync(progPath, 'utf8');

    // Remove existing blocks if present
    if (content.includes(`DOWNLOAD F,"${code}.BAS"`)) {
        console.log(`Prog_Gestmag.BAS contains ${code}, updating...`);
        const basRegex = new RegExp(`DOWNLOAD F,"${code}.BAS"[\\s\\S]*?EOP`, 'g');
        const iniRegex = new RegExp(`DOWNLOAD F,"${code}.INI"[\\s\\S]*?EOP`, 'g');
        content = content.replace(basRegex, '');
        content = content.replace(iniRegex, '');
        // Clean up potential double newlines left behind
        content = content.replace(/^\s*[\r\n]/gm, '\n').replace(/\n\n+/g, '\n\n');
    }

    const insertionBlock = `\n${basBlock}\n${iniBlock}\n`;
    const lastEopIndex = content.lastIndexOf("EOP");

    if (lastEopIndex !== -1) {
        const insertPos = lastEopIndex + 3;
        content = content.slice(0, insertPos) + insertionBlock + content.slice(insertPos);
    } else {
        content += insertionBlock;
    }

    fs.writeFileSync(progPath, content, 'utf8');
    console.log(`Updated Prog_Gestmag.BAS with ${code}`);
}

function cleanupProgGestmag(code) {
    const progPath = path.join(WORK_DIR, 'Prog_Gestmag.BAS');
    if (!fs.existsSync(progPath)) return;

    let content = fs.readFileSync(progPath, 'utf8');
    if (!content.includes(code)) return;

    // Remove blocks
    const basRegex = new RegExp(`DOWNLOAD F,"${code}.BAS"[\\s\\S]*?EOP`, 'g');
    const iniRegex = new RegExp(`DOWNLOAD F,"${code}.INI"[\\s\\S]*?EOP`, 'g');

    content = content.replace(basRegex, '');
    content = content.replace(iniRegex, '');

    // Clean up extra newlines
    content = content.replace(/^\s*[\r\n]/gm, '\n').replace(/\n\n+/g, '\n\n');

    fs.writeFileSync(progPath, content, 'utf8');
    console.log(`Removed ${code} from Prog_Gestmag.BAS`);
}

function updateAutoBas(filename) {
    const autoPath = path.join(WORK_DIR, 'AUTO.BAS');
    if (!fs.existsSync(autoPath)) return;

    let content = fs.readFileSync(autoPath, 'utf8');
    const searchStr = `COPY E,"${filename}" ,F,"${filename}"`;

    if (content.includes(searchStr)) return;

    const lastCopyMatch = content.match(/COPY E,".*?" ,F,".*?"/g);
    if (lastCopyMatch) {
        const lastCopyLine = lastCopyMatch[lastCopyMatch.length - 1];
        const index = content.lastIndexOf(lastCopyLine);

        if (index !== -1) {
            const endOfLine = content.indexOf('\n', index) + 1;
            const newLine = `\tCOPY E,"${filename}" ,F,"${filename}"\r\n`;
            content = content.slice(0, endOfLine) + newLine + content.slice(endOfLine);
            fs.writeFileSync(autoPath, content, 'utf8');
            console.log(`Updated AUTO.BAS with ${filename}`);
            return;
        }
    }
    content += `\nCOPY E,"${filename}" ,F,"${filename}"\n`;
    fs.writeFileSync(autoPath, content, 'utf8');
}

function cleanupAutoBas(filename) {
    const autoPath = path.join(WORK_DIR, 'AUTO.BAS');
    if (!fs.existsSync(autoPath)) return;

    let content = fs.readFileSync(autoPath, 'utf8');

    const lines = content.split(/\r?\n/);
    const newLines = lines.filter(line => !line.toLowerCase().includes(`copy e,"${filename.toLowerCase()}"`));

    if (lines.length !== newLines.length) {
        fs.writeFileSync(autoPath, newLines.join('\r\n'), 'utf8');
        console.log(`Removed ${filename} from AUTO.BAS`);
    }
}

function handleGenerateManual(req, res) {
    let body = '';
    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        try {
            // 1. Scanner les fichiers BMP dans le répertoire
            const allFiles = fs.readdirSync(WORK_DIR);
            const bmpFiles = allFiles
                .filter(file => file.toLowerCase().endsWith('.bmp'))
                // Exclure les fichiers système, temporaires ET 'USB'
                .filter(file => !file.startsWith('Logo_GM') && !file.startsWith('.') && !file.toUpperCase().startsWith('USB'));

            const totalTemplates = bmpFiles.length;
            const currentDate = new Date().toLocaleDateString('fr-FR', {
                day: '2-digit',
                month: 'long',
                year: 'numeric'
            });

            // 2. Grouper les fichiers par préfixe
            const groups = {};

            bmpFiles.forEach(file => {
                const upperFile = file.toUpperCase();
                // Extraire le code (nom sans extension)
                const code = path.parse(file).name.toUpperCase();

                // Trouver le préfixe
                let prefix = code.replace(/[0-9]/g, ''); // Enlever les chiffres

                // Special handling for 40x27 templates
                const code40x27 = ['1', '2', '3', '4', '5', '10'];
                let categoryName;

                if (code40x27.includes(code)) {
                    categoryName = '40x27';
                    prefix = '40x27'; // To avoid empty parentheses in title
                } else {
                    // Cas particuliers ou nettoyage
                    if (prefix === 'M' || prefix === 'MAR') {
                        // Laisser tel quel, le mapping gérera
                    }
                    categoryName = CATEGORY_MAPPINGS[prefix] || prefix;
                }

                if (!groups[categoryName]) {
                    groups[categoryName] = {
                        prefix: prefix,
                        name: categoryName,
                        files: []
                    };
                } else {
                    // Si on trouve un préfixe plus long pour la même catégorie, on l'utilise
                    // Ex: PRO vs PR -> On garde PRO
                    if (prefix.length > groups[categoryName].prefix.length) {
                        groups[categoryName].prefix = prefix;
                    }
                }
                groups[categoryName].files.push({
                    file: file,
                    code: code,
                    // Essayer de parser le numéro pour le tri
                    number: parseInt(code.match(/\d+/)?.[0] || 0)
                });
            });

            // 3. Lire le template de manuel existant pour récupérer l'en-tête
            const manualTemplatePath = path.join(WORK_DIR, 'manuel_brother_td4t.html');
            if (!fs.existsSync(manualTemplatePath)) {
                res.writeHead(404, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: "Template de manuel introuvable" }));
                return;
            }

            let originalContent = fs.readFileSync(manualTemplatePath, 'utf8');

            // On veut conserver tout ce qui est avant le catalogue
            // Marqueur : <h2>📊 Catalogue des Templates
            const marker = '<h2>📊 Catalogue des Templates';
            const splitIndex = originalContent.indexOf(marker);

            let headerContent = '';
            if (splitIndex !== -1) {
                headerContent = originalContent.substring(0, splitIndex);
            } else {
                // Fallback si on ne trouve pas le marqueur (peu probable)
                headerContent = originalContent;
            }

            // Mettre à jour les stats dans le header si présent (au cas où on regénère sur un généré)
            // Mais ici on prend le fichier source HTML, donc on peut juste reconstruire la ligne de titre

            // 4. Construire le contenu HTML
            let newContent = headerContent;

            // Ajouter le titre du catalogue mis à jour
            newContent += `<h2>📊 Catalogue des Templates (${totalTemplates} modèles disponibles)</h2>\n\n`;

            // Trier les catégories par nom
            const sortedCategories = Object.keys(groups).sort();

            sortedCategories.forEach(catName => {
                const group = groups[catName];
                // Trier les fichiers par numéro
                group.files.sort((a, b) => a.number - b.number);

                newContent += `        <div class="category">\n`;
                newContent += `            <h3>${getCategoryIcon(catName)} ${catName} (${group.prefix}) - ${group.files.length} modèles</h3>\n`;
                newContent += `            <div class="template-grid">\n`;

                group.files.forEach(item => {
                    newContent += `                <div class="template-item">\n`;
                    newContent += `                    <div class="template-code">${item.code}</div>`;
                    // Image chemin relatif
                    newContent += `<img src="${item.file}" alt="${item.code}">`;
                    newContent += `\n                </div>\n`;
                });

                newContent += `            </div>\n`;
                newContent += `        </div>\n\n`;
            });

            // Ajouter le footer
            newContent += `        <footer>
            <div class="info-box" style="text-align: center; margin-top: 40px; color: #666;">
                <p>Document généré automatiquement le ${currentDate}</p>
                <!-- Branding removed -->
                <p>${totalTemplates} modèles indexés (Images système exclues)</p>
                <p style="margin-top: 10px; font-size: 0.9em;">Développé par Clément CAHAGNE</p>
            </div>
        </footer>
    </div>
</body>
</html>`;

            // Sauvegarder le manuel généré
            const outputPath = path.join(WORK_DIR, 'manuel_brother_td4t_generated.html');
            fs.writeFileSync(outputPath, newContent, 'utf8');

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                success: true,
                message: `Manuel généré avec succès : ${totalTemplates} templates`,
                filePath: 'manuel_brother_td4t_generated.html',
                totalTemplates: totalTemplates
            }));

        } catch (e) {
            console.error('Erreur lors de la génération du manuel:', e);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: "Erreur lors de la génération du manuel" }));
        }
    });
}

function handlePrepareUsb(req, res) {
    let body = '';
    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        try {
            const data = JSON.parse(body);
            let { driveLetter } = data;

            if (!driveLetter) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: "Lettre de lecteur manquante" }));
                return;
            }

            // Nettoyage de la lettre (ex: "e" -> "E:")
            driveLetter = driveLetter.toUpperCase().replace(/[^A-Z]/g, '');
            if (driveLetter.length !== 1) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: "Lettre de lecteur invalide (A-Z)" }));
                return;
            }

            const destRoot = `${driveLetter}:/`;

            // Vérifier si le lecteur est accessible (écriture test)
            try {
                fs.accessSync(destRoot, fs.constants.W_OK);
            } catch (err) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: `Le lecteur ${destRoot} n'est pas accessible ou inscriptible.` }));
                return;
            }

            // Liste des fichiers à copier
            const allFiles = fs.readdirSync(WORK_DIR);

            // 1. BMP Templates (Exclure USB)
            const bmpFiles = allFiles.filter(file =>
                file.toLowerCase().endsWith('.bmp') &&
                !file.toUpperCase().startsWith('USB')
            );

            // 2. Fichiers Systèmes
            const sysFiles = ['AUTO.BAS', 'Prog_Gestmag.BAS', 'AUTO.TXT'];

            let copiedCount = 0;
            let skippedCount = 0;
            let errors = [];

            const copyIfModified = (filename) => {
                const srcPath = path.join(WORK_DIR, filename);
                const destPath = path.join(destRoot, filename);

                if (!fs.existsSync(srcPath)) return; // Should not happen for listed files

                try {
                    let shouldCopy = true;

                    if (fs.existsSync(destPath)) {
                        const srcStat = fs.statSync(srcPath);
                        const destStat = fs.statSync(destPath);

                        // Copy if size differs or source is newer (allowing 2s precision diff for FAT systems)
                        const timeDiff = srcStat.mtimeMs - destStat.mtimeMs;
                        if (srcStat.size === destStat.size && timeDiff <= 2000) {
                            shouldCopy = false;
                        }
                    }

                    if (shouldCopy) {
                        fs.copyFileSync(srcPath, destPath);
                        copiedCount++;
                    } else {
                        skippedCount++;
                    }
                } catch (e) {
                    errors.push(`Erreur copie ${filename}: ${e.message}`);
                }
            };

            // Copie BMPs
            bmpFiles.forEach(file => copyIfModified(file));

            // Copie SysFiles
            sysFiles.forEach(file => copyIfModified(file));

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                success: true,
                message: `Clé USB mise à jour ! (${copiedCount} copiés, ${skippedCount} ignorés)`,
                details: errors.length > 0 ? errors : null
            }));

        } catch (e) {
            console.error('Erreur USB:', e);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: "Erreur serveur lors de la préparation USB" }));
        }
    });
}

function getCategoryIcon(category) {
    const icons = {
        'ABATTAGE': '🏪',
        'AMOUR': '❤️',
        'BARBECUE': '🍺',
        'BOUCHERIE': '🥩',
        'COMPOSITION': '📋',
        'FÊTES': '🎄',
        'FRAICHE DECOUPE': '🔪',
        'MAISON': '🏠',
        'MARCHÉ': '🏷️',
        'MAREE': '🐟',
        'ORIGINE': '🌟',
        'PIZZA': '🍕',
        'PREPARATION': '👨‍🍳',
        'PROMO': '💰',
        'VIA': '🚚'
    };
    return icons[category] || '📦';
}

server.on('error', (e) => {
    if (e.code === 'EADDRINUSE') {
        console.log(`\n⚠️  ATTENTION : Le port ${PORT} est déjà utilisé.`);
        console.log(`   Cela signifie que le serveur est DÉJÀ LANCÉ en arrière-plan.`);
        console.log(`   Inutile de le relancer. Vous pouvez accéder à l'application ici : http://localhost:${PORT}/`);
        process.exit(0);
    } else {
        console.error('Erreur serveur:', e);
    }
});

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
    console.log('Press Ctrl+C to stop');
});

function extractMetadataFromBas() {
    const progPath = path.join(WORK_DIR, 'Prog_Gestmag.BAS');
    if (!fs.existsSync(progPath)) return {};

    const content = fs.readFileSync(progPath, 'utf8');
    const metadata = {};

    // 1. Extract X/Y from BAS blocks
    // Pattern: DOWNLOAD F,"CODE.BAS" ... PUTBMP X, Y ...
    const basRegex = /DOWNLOAD F,"(.*?)\.BAS"[\s\S]*?PUTBMP\s+(\d+),\s+(\d+)/gi;
    let match;
    while ((match = basRegex.exec(content)) !== null) {
        const code = match[1].toUpperCase();
        const x = parseInt(match[2]);
        const y = parseInt(match[3]);
        if (!metadata[code]) metadata[code] = {};
        metadata[code].positionX = x;
        metadata[code].positionY = y;
    }

    // 2. Extract CropTop from INI blocks
    // Pattern: DOWNLOAD F,"CODE.INI" ... REM - CROPTOP = Val
    const iniRegex = /DOWNLOAD F,"(.*?)\.INI"[\s\S]*?REM - CROPTOP\s*=\s*(\d+)/gi;
    let cropMatch;
    while ((cropMatch = iniRegex.exec(content)) !== null) {
        const code = cropMatch[1].toUpperCase();
        const crop = parseInt(cropMatch[2]);
        if (!metadata[code]) metadata[code] = {};
        metadata[code].cropTop = crop;
    }

    return metadata;
}
