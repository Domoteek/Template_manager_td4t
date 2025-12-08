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

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const parsedUrl = url.parse(req.url, true);

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
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ message: "Ready" }));
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
        PUTBMP ${positionX || 8}, ${positionY || 22}, "${lowerCode}.bmp", 1 
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
            // Scanner les fichiers BMP dans le répertoire
            const bmpFiles = fs.readdirSync(WORK_DIR)
                .filter(file => file.toLowerCase().endsWith('.bmp'))
                .filter(file => /^(aba|amo|bar|bou|com|fet|fra|m|mar|ori|piz|pre|pro)\d+/i.test(file));

            const totalTemplates = bmpFiles.length;
            const currentDate = new Date().toLocaleDateString('fr-FR', {
                day: '2-digit',
                month: 'long',
                year: 'numeric'
            });

            // Lire le template de manuel existant
            const manualTemplatePath = path.join(WORK_DIR, 'manuel_brother_td4t.html');
            if (!fs.existsSync(manualTemplatePath)) {
                res.writeHead(404, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: "Template de manuel introuvable" }));
                return;
            }

            let htmlContent = fs.readFileSync(manualTemplatePath, 'utf8');

            // Mettre à jour le compteur de templates et la date
            htmlContent = htmlContent.replace(/98 mod.?les disponibles/g, `${totalTemplates} modèles disponibles`);
            htmlContent = htmlContent.replace(/\d{2,} [a-zA-Z]+ \d{4}/g, currentDate);
            
            // Mettre à jour le footer
            htmlContent = htmlContent.replace(/Version 2\.0 • \d{2} [a-zA-Z]+ \d{4} • \d+ Templates disponibles/g, 
                `Version 2.0 • ${currentDate} • ${totalTemplates} Templates disponibles`);

            // Remplacer les chemins absolus des images par des chemins relatifs
            const basePath = 'c:/_DONNEES/_travail client/Travail BRother etiquettes/Brother/Definitif BMP 46x46 FR/';
            const escapedPath = basePath.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/\s+/g, '\\s+');
            const pathRegex = new RegExp(escapedPath, 'gi');
            htmlContent = htmlContent.replace(pathRegex, '/');

            // Vérifier si ABA04 existe et l'ajouter s'il manque
            if (bmpFiles.includes('aba04.bmp') && !htmlContent.includes('ABA04')) {
                // Trouver la section ABAT
                const abatSectionStart = htmlContent.indexOf('<div class="category">');
                let abatSectionEnd = htmlContent.indexOf('</div>\n</div>', abatSectionStart);
                
                // Chercher la fin de la section ABAT (après le template-grid)
                let tempIndex = abatSectionStart;
                let depth = 0;
                while (tempIndex < htmlContent.length) {
                    if (htmlContent.substr(tempIndex, 6) === '<div c') {
                        depth++;
                    } else if (htmlContent.substr(tempIndex, 6) === '</div>') {
                        depth--;
                        if (depth === 0) {
                            abatSectionEnd = tempIndex + 6;
                            break;
                        }
                    }
                    tempIndex++;
                }
                
                if (abatSectionStart !== -1 && abatSectionEnd !== -1) {
                    const abatSection = htmlContent.substring(abatSectionStart, abatSectionEnd);
                    
                    // Mettre à jour le compteur de modèles dans la section ABAT (3 -> 4)
                    const updatedAbatSection = abatSection.replace(
                        /ABATTAGE \(ABA\) - 3 modèles/,
                        'ABATTAGE (ABA) - 4 modèles'
                    );
                    
                    // Ajouter ABA04 avant la fermeture du template-grid
                    const templateGridEnd = updatedAbatSection.indexOf('</div>\n</div>');
                    if (templateGridEnd !== -1) {
                        const beforeGridEnd = updatedAbatSection.substring(0, templateGridEnd);
                        const afterGridEnd = updatedAbatSection.substring(templateGridEnd);
                        
                        const newTemplateItem = `                <div class="template-item">
                    <div class="template-code">ABA04</div><img
                        src="/aba04.bmp"
                        alt="ABA04">
                </div>
`;
                        
                        const finalAbatSection = beforeGridEnd + newTemplateItem + afterGridEnd;
                        htmlContent = htmlContent.substring(0, abatSectionStart) + finalAbatSection + htmlContent.substring(abatSectionEnd);
                    }
                }
            }

            // Sauvegarder le manuel généré
            const outputPath = path.join(WORK_DIR, 'manuel_brother_td4t_generated.html');
            fs.writeFileSync(outputPath, htmlContent, 'utf8');

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

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
    console.log('Press Ctrl+C to stop');
});
