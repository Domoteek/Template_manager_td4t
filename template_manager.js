// Template Manager - JavaScript
class TemplateManager {
    constructor() {
        this.templates = this.loadTemplates();
        this.editingTemplateId = null;
        this.init();
    }

    init() {
        this.setupEventListeners();
        // Charger depuis le serveur au lieu du localStorage direct
        this.fetchTemplatesFromServer();
    }

    async fetchTemplatesFromServer() {
        try {
            const response = await fetch('/api/list-templates');
            if (response.ok) {
                const serverTemplates = await response.json();

                // Fusionner avec les métadonnées locales (description, positions) si existantes
                const localData = this.loadLocalMetadata();

                this.templates = serverTemplates.map(t => {
                    const local = localData[t.code] || {};
                    return {
                        id: Date.now() + Math.random(), // ID front temporaire
                        ...t,
                        category: t.category || local.category,
                        description: local.description || `Template ${t.category}`, // Description par défaut si vide
                        positionX: local.positionX || 22,
                        positionY: local.positionY || 22,
                        cropTop: local.cropTop || 0,
                        // Conserver les dates si dispos
                        createdAt: local.createdAt || new Date().toISOString()
                    };
                });

                this.renderTemplates();
                this.updatePreview();
                this.showToast('Liste des templates mise à jour', 'success');
            } else {
                console.error('Erreur chargement templates:', await response.text());
                this.loadFallbackTemplates();
            }
        } catch (e) {
            console.error('Erreur connexion serveur:', e);
            this.showToast('Mode hors ligne : chargement local', 'warning');
            this.loadFallbackTemplates();
        }
    }

    loadLocalMetadata() {
        const stored = localStorage.getItem('brotherTemplatesMetadata');
        return stored ? JSON.parse(stored) : {};
    }

    saveLocalMetadata() {
        // Sauvegarder uniquement les métadonnées utiles indexées par Code
        const metadata = {};
        this.templates.forEach(t => {
            metadata[t.code] = {
                description: t.description,
                positionX: t.positionX,
                positionY: t.positionY,
                cropTop: t.cropTop,
                category: t.category,
                createdAt: t.createdAt
            };
        });
        localStorage.setItem('brotherTemplatesMetadata', JSON.stringify(metadata));
    }

    // Ancien loadTemplates (renommé/supprimé dans la pratique, remplacé par fetchTemplatesFromServer)
    loadFallbackTemplates() {
        const stored = localStorage.getItem('brotherTemplates');
        if (stored) {
            try {
                this.templates = JSON.parse(stored);
                this.renderTemplates();
            } catch (e) {
                this.templates = this.getDefaultTemplates();
                this.renderTemplates();
            }
        } else {
            this.templates = this.getDefaultTemplates();
            this.renderTemplates();
        }
    }

    // Mise à jour de saveTemplates pour utiliser saveLocalMetadata
    saveTemplates() {
        // On ne sauvegarde plus toute la liste dans localStorage comme source de vérité
        // mais on sauvegarde les métadonnées pour les réappliquer au prochain fetch
        this.saveLocalMetadata();

        // Optionnel : garder brotherTemplates pour le fallback hors ligne
        localStorage.setItem('brotherTemplates', JSON.stringify(this.templates));
    }

    setupEventListeners() {
        // Form submission
        const form = document.getElementById('templateForm');
        form.addEventListener('submit', (e) => this.handleFormSubmit(e));

        // File input change
        const fileInput = document.getElementById('imageFile');
        fileInput.addEventListener('change', (e) => this.handleFileChange(e));

        // Real-time preview updates
        document.getElementById('templateCode').addEventListener('input', () => this.updatePreview());
        document.getElementById('templateName').addEventListener('input', () => this.updatePreview());
        document.getElementById('positionX').addEventListener('input', () => this.updatePreview());
        document.getElementById('positionY').addEventListener('input', () => this.updatePreview());
        document.getElementById('cropTop').addEventListener('input', () => this.updatePreview());

        // Search functionality
        const searchInput = document.getElementById('searchInput');
        searchInput.addEventListener('input', (e) => this.handleSearch(e.target.value));

        // Category filter
        const categoryFilter = document.getElementById('categoryFilter');
        categoryFilter.addEventListener('change', (e) => this.handleCategoryFilter(e.target.value));

        // Category selection for new template
        const templateCategory = document.getElementById('templateCategory');
        templateCategory.addEventListener('change', (e) => this.suggestTemplateCode(e.target.value));

        // Cancel edit button
        const cancelBtn = document.getElementById('cancelEditBtn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => this.cancelEdit());
        }

        // File upload drag and drop
        const uploadWrapper = document.querySelector('.file-upload-wrapper');
        uploadWrapper.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.stopPropagation();
            uploadWrapper.querySelector('.file-upload-display').style.borderColor = 'var(--primary-400)';
        });

        uploadWrapper.addEventListener('dragleave', (e) => {
            e.preventDefault();
            e.stopPropagation();
            uploadWrapper.querySelector('.file-upload-display').style.borderColor = 'var(--border-color)';
        });

        uploadWrapper.addEventListener('drop', (e) => {
            e.preventDefault();
            e.stopPropagation();
            uploadWrapper.querySelector('.file-upload-display').style.borderColor = 'var(--border-color)';

            const files = e.dataTransfer.files;
            if (files.length > 0) {
                fileInput.files = files;
                this.handleFileChange({ target: fileInput });
            }
        });
    }

    async handleFormSubmit(e) {
        e.preventDefault();

        const formData = new FormData(e.target);
        const code = formData.get('templateCode').toUpperCase();
        const category = formData.get('templateCategory');
        const description = formData.get('templateDescription');
        let positionX = parseInt(formData.get('positionX'));
        if (isNaN(positionX)) positionX = 22;

        let positionY = parseInt(formData.get('positionY'));
        if (isNaN(positionY)) positionY = 22;

        let cropTop = parseInt(formData.get('cropTop'));
        if (isNaN(cropTop)) cropTop = 0;

        if (this.editingTemplateId) {
            // Check if code changed and if it conflicts
            const existing = this.templates.find(t => t.id === this.editingTemplateId);
            if (code !== existing.code && this.templates.some(t => t.code === code)) {
                this.showToast(`Le code "${code}" existe déjà.`, 'error');
                return;
            }
        } else {
            // Check for duplicate code
            if (this.templates.some(t => t.code === code)) {
                this.showToast(`Le code "${code}" existe déjà.`, 'error');
                return;
            }
        }

        // Auto-generate name from code and category
        const name = `${category} ${code.substring(3)}`;

        let imageData = document.getElementById('previewImage').src;

        // If editing and no new file selected, use original image data to avoid absolute path conversion
        if (this.editingTemplateId && document.getElementById('imageFile').files.length === 0) {
            const original = this.templates.find(t => t.id === this.editingTemplateId);
            if (original) {
                imageData = original.imageData;
            }
        }

        if (!imageData || imageData === '') {
            this.showToast('Veuillez sélectionner une image', 'error');
            return;
        }

        const template = {
            id: this.editingTemplateId || Date.now(),
            code: code,
            name: name,
            description: description,
            category: category,
            positionX: positionX,
            positionY: positionY,
            cropTop: cropTop,
            imageData: imageData,
            createdAt: this.editingTemplateId ? undefined : new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        if (this.editingTemplateId) {
            // Preserve creation date
            const original = this.templates.find(t => t.id === this.editingTemplateId);
            if (original) template.createdAt = original.createdAt;
            this.showToast('Mise à jour du template...', 'warning');
        } else {
            this.showToast('Installation du template en cours...', 'warning');
        }

        // Send to Server
        this.saveTemplateToServer(template).then(success => {
            if (success) {
                if (this.editingTemplateId) {
                    // Update in place
                    const idx = this.templates.findIndex(t => t.id === this.editingTemplateId);
                    if (idx !== -1) {
                        this.templates[idx] = { ...this.templates[idx], ...template };
                    }
                    this.cancelEdit();
                } else {
                    // Add new
                    this.templates.push(template);
                }

                this.saveTemplates();

                // Get current filter values before rendering (capture at response time)
                const searchQuery = document.getElementById('searchInput').value;
                const category = document.getElementById('categoryFilter').value;
                this.renderTemplates(searchQuery, category);

                if (!this.editingTemplateId) {
                    e.target.reset();
                    this.hidePreview();
                }
            }
        });
    }

    editTemplate(id) {
        const template = this.templates.find(t => t.id === id);
        if (!template) return;

        this.editingTemplateId = id;

        // Populate fields
        const codeInput = document.getElementById('templateCode');
        codeInput.value = template.code;
        document.getElementById('templateName').value = template.name;
        document.getElementById('templateCategory').value = template.category || '';
        document.getElementById('templateDescription').value = template.description || '';
        document.getElementById('positionX').value = template.positionX;
        document.getElementById('positionY').value = template.positionY;
        document.getElementById('cropTop').value = template.cropTop || 0;

        // Update UI state
        // Manually trigger input event on code to hide helper text if needed
        codeInput.dispatchEvent(new Event('input'));

        const submitBtn = document.getElementById('submitBtn');
        submitBtn.innerHTML = `
            <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
                <polyline points="17 21 17 13 7 13 7 21"></polyline>
                <polyline points="7 3 7 8 15 8"></polyline>
            </svg>
            Mettre à jour
        `;
        document.getElementById('cancelEditBtn').style.display = 'flex';

        // Show existing image in preview
        const previewImage = document.getElementById('previewImage');
        previewImage.src = template.imageData; // Will be base64 or relative path
        this.showPreview();
        this.updateFileUploadDisplay('Image actuelle conservée');

        this.updatePreview();

        // Scroll to form top (new selector)
        document.querySelector('.editor-container').scrollIntoView({ behavior: 'smooth' });

        // Make image file optional
        const fileInput = document.getElementById('imageFile');
        fileInput.required = false;
        fileInput.value = ''; // Clear any previous selection
    }

    cancelEdit() {
        this.editingTemplateId = null;

        // Reset form
        document.getElementById('templateForm').reset();
        this.hidePreview();

        // Reset buttons
        document.getElementById('submitBtn').innerHTML = `
            <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
            Ajouter le template
        `;
        document.getElementById('cancelEditBtn').style.display = 'none';
        this.updateFileUploadDisplay('Choisir une image...');

        // Restore image file requirement
        document.getElementById('imageFile').required = true;
    }

    async saveTemplateToServer(template) {
        try {
            const response = await fetch('/api/save-template', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(template)
            });

            const result = await response.json();

            if (response.ok) {
                const action = this.editingTemplateId ? "mis à jour" : "installé";
                this.showToast(`Template "${template.code}" ${action} avec succès !`, 'success');
                return true;
            } else {
                this.showToast(`Erreur serveur: ${result.error}`, 'error');
                return false;
            }
        } catch (error) {
            console.error('Error saving template:', error);
            this.showToast('Erreur de connexion au serveur local', 'error');
            return false;
        }
    }

    handleFileChange(e) {
        const file = e.target.files[0];
        if (!file) return;

        // Validate file type
        if (!file.type.startsWith('image/')) {
            this.showToast('Veuillez sélectionner un fichier image valide', 'error');
            return;
        }

        // Validate file size (10MB max)
        if (file.size > 10 * 1024 * 1024) {
            this.showToast('La taille du fichier ne doit pas dépasser 10MB', 'error');
            return;
        }

        // Read and resize image
        const reader = new FileReader();
        reader.onload = (event) => {
            this.resizeAndProcessImage(event.target.result, file.name);
        };
        reader.readAsDataURL(file);
    }

    resizeAndProcessImage(imageDataUrl, filename) {
        // Create an image element to load the uploaded image
        const img = new Image();
        img.onload = () => {
            try {
                // Get cropTop value from form
                const cropTopInput = document.getElementById('cropTop');
                const cropTop = cropTopInput ? parseInt(cropTopInput.value) || 0 : 0;

                // Validate cropTop value
                if (cropTop < 0 || cropTop >= img.height) {
                    this.showToast('Valeur de rognage invalide', 'error');
                    return;
                }

                // Use the shared 1-bit BMP conversion logic with cropping
                const blob = this.convertImageTo1BitBmpBlob(img, cropTop);

                // Convert Blob to Base64 for preview and storage
                const reader = new FileReader();
                reader.onloadend = () => {
                    const base64BMP = reader.result;

                    // Update preview
                    const previewImage = document.getElementById('previewImage');
                    previewImage.src = base64BMP;

                    // Auto-set positions to standard values
                    document.getElementById('positionX').value = 22;
                    document.getElementById('positionY').value = 22;

                    this.showPreview();
                    this.updateFileUploadDisplay(filename);
                    this.showToast(`Image traitée (1-bit)${cropTop > 0 ? `, rognée de ${cropTop}px` : ''}`, 'success');
                };
                reader.onerror = () => {
                    this.showToast('Erreur lors du traitement du fichier', 'error');
                };
                reader.readAsDataURL(blob);

            } catch (e) {
                console.error(e);
                this.showToast('Erreur lors de la conversion de l\'image', 'error');
            }
        };

        img.onerror = () => {
            this.showToast('Erreur lors du chargement de l\'image', 'error');
        };

        img.src = imageDataUrl;
    }

    updateFileUploadDisplay(filename) {
        const uploadText = document.querySelector('.upload-text');
        uploadText.textContent = filename;
        uploadText.style.color = 'var(--primary-400)';
    }

    showPreview() {
        const previewImg = document.getElementById('previewImage');
        const placeholder = document.querySelector('.preview-placeholder');

        previewImg.style.display = 'block';
        if (placeholder) placeholder.style.display = 'none';

        this.updatePreview();
    }

    hidePreview() {
        // Reset preview items
        const previewImg = document.getElementById('previewImage');
        const placeholder = document.querySelector('.preview-placeholder');

        previewImg.src = '';
        previewImg.style.display = 'none';
        if (placeholder) placeholder.style.display = 'block';

        // Reset file upload display
        this.updateFileUploadDisplay('Choisir une image...');
    }

    updatePreview() {
        const code = document.getElementById('templateCode').value.toUpperCase();
        const category = document.getElementById('templateCategory').value;
        const posX = document.getElementById('positionX').value || 22;
        const posY = document.getElementById('positionY').value || 22;

        // Auto-generate name from code and category
        const name = category && code ? `${category} ${code.substring(3)}` : '-';

        document.getElementById('previewCode').textContent = code || '-';
        document.getElementById('previewName').textContent = name;
        document.getElementById('previewPosition').textContent = `X: ${posX}, Y: ${posY}`;
    }

    renderTemplates(filter = '', category = '') {
        const grid = document.getElementById('templatesGrid');
        let filteredTemplates = this.templates;

        // Apply category filter
        if (category) {
            filteredTemplates = filteredTemplates.filter(t => t.category === category);
        }

        // Apply search filter
        if (filter) {
            filteredTemplates = filteredTemplates.filter(t =>
                t.code.toLowerCase().includes(filter.toLowerCase()) ||
                t.name.toLowerCase().includes(filter.toLowerCase()) ||
                (t.description && t.description.toLowerCase().includes(filter.toLowerCase()))
            );
        }

        if (filteredTemplates.length === 0) {
            grid.innerHTML = `
                <div style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-tertiary);">
                    <svg style="width: 4rem; height: 4rem; margin: 0 auto 1rem; stroke: var(--text-tertiary);" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="8" x2="12" y2="12"></line>
                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                    </svg>
                    <p style="font-size: 1.125rem;">Aucun template trouvé</p>
                    <p style="font-size: 0.875rem; margin-top: 0.5rem;">${category ? 'Essayez une autre catégorie' : 'Ajoutez votre premier template ci-dessus'}</p>
                </div>
            `;
            return;
        }

        grid.innerHTML = filteredTemplates.map(template => {
            // Pour les templates existants, utiliser le chemin relatif vers le fichier BMP
            const imageSrc = template.isExisting ? template.imageData : template.imageData;
            const categoryBadge = template.category ? `<span class="category-badge">${template.category}</span>` : '';

            return `
            <div class="template-card" data-id="${template.id}">
                <div class="template-card-image">
                    <img src="${imageSrc}" alt="${template.name}" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22100%22 height=%22100%22%3E%3Crect fill=%22%23ddd%22 width=%22100%22 height=%22100%22/%3E%3Ctext fill=%22%23999%22 x=%2250%25%22 y=%2250%25%22 text-anchor=%22middle%22 dy=%22.3em%22%3E${template.code}%3C/text%3E%3C/svg%3E'">
                </div>
                <div class="template-card-content">
                    <div class="template-card-header">
                        <div style="display: flex; gap: 0.5rem; align-items: center;">
                            <span class="template-code">${template.code}</span>
                            ${categoryBadge}
                        </div>
                        <div class="template-card-actions">
                            <button class="icon-btn" onclick="templateManager.editTemplate(${template.id})" title="Modifier">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                </svg>
                            </button>
                            <button class="icon-btn" onclick="templateManager.viewTemplate(${template.id})" title="Voir l'image">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                            <button class="icon-btn delete" onclick="templateManager.deleteTemplate(${template.id})" title="Supprimer">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <polyline points="3 6 5 6 21 6"></polyline>
                                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                    <h3 class="template-name">${template.name}</h3>
                    ${template.description ? `<p class="template-description">${template.description}</p>` : ''}
                    <div class="template-meta">
                        <span>Position: ${template.positionX}, ${template.positionY}</span>
                        <span>•</span>
                        <span>${new Date(template.createdAt).toLocaleDateString('fr-FR')}</span>
                    </div>
                </div>
            </div>
        `;
        }).join('');
    }

    handleSearch(query) {
        const category = document.getElementById('categoryFilter').value;
        this.renderTemplates(query, category);
    }

    handleCategoryFilter(category) {
        const searchQuery = document.getElementById('searchInput').value;
        this.renderTemplates(searchQuery, category);
    }

    suggestTemplateCode(category) {
        if (!category) {
            document.getElementById('templateCode').value = '';
            document.getElementById('codeHelper').textContent = 'Code auto-généré selon la catégorie';
            return;
        }

        // Map categories to their code prefixes (optional overrides)
        const categoryPrefixes = {
            // Add specific overrides here if needed
        };

        let prefix = categoryPrefixes[category];

        // Default: First 3 letters, uppercase, no accents
        if (!prefix) {
            prefix = category.substring(0, 3)
                .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                .toUpperCase();
        }

        if (!prefix || prefix.length < 3) {
            console.warn('Could not generate prefix for:', category);
            return;
        }

        // Ensure templates array exists
        if (!this.templates) {
            this.templates = [];
        }

        // Find all existing codes with this prefix
        const existingCodes = this.templates
            .filter(t => t.code && t.code.startsWith(prefix))
            .map(t => {
                // Extract the numeric part
                const numPart = t.code.substring(prefix.length);
                return parseInt(numPart) || 0;
            })
            .sort((a, b) => a - b);

        // Find the next available number
        let nextNumber = 1;
        for (let i = 0; i < existingCodes.length; i++) {
            if (existingCodes[i] === nextNumber) {
                nextNumber++;
            } else {
                break;
            }
        }

        // Format the code with leading zero if needed
        const suggestedCode = prefix + String(nextNumber).padStart(2, '0');

        const codeInput = document.getElementById('templateCode');
        if (codeInput) {
            codeInput.value = suggestedCode;
            codeInput.dispatchEvent(new Event('input'));
        }

        const helper = document.getElementById('codeHelper');
        if (helper) {
            helper.textContent = `Prochain code disponible pour ${category}`;
            helper.style.color = 'var(--success)';
        }

        this.updatePreview();
    }

    viewTemplate(id) {
        const template = this.templates.find(t => t.id === id);
        if (!template) return;

        // Ouvrir l'image dans une nouvelle fenêtre
        const win = window.open('', '_blank');
        win.document.write(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>${template.code} - ${template.name}</title>
                <style>
                    body {
                        margin: 0;
                        padding: 20px;
                        background: #0a0e1a;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        min-height: 100vh;
                        font-family: 'Inter', sans-serif;
                        color: #f8fafc;
                    }
                    .info {
                        margin-bottom: 20px;
                        text-align: center;
                    }
                    .code {
                        font-size: 24px;
                        font-weight: 700;
                        color: #a78bfa;
                        margin-bottom: 8px;
                    }
                    .name {
                        font-size: 18px;
                        color: #cbd5e1;
                    }
                    img {
                        max-width: 90vw;
                        max-height: 80vh;
                        border: 2px solid #1e293b;
                        border-radius: 8px;
                        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.4);
                        background: white;
                    }
                </style>
            </head>
            <body>
                <div class="info">
                    <div class="code">${template.code}</div>
                    <div class="name">${template.name}</div>
                </div>
                <img src="${template.imageData}" alt="${template.name}">
            </body>
            </html>
        `);
    }


    deleteTemplate(id) {
        const template = this.templates.find(t => t.id === id);
        if (!template) return;

        const modal = document.getElementById('confirmModal');
        const confirmBtn = document.getElementById('confirmDeleteBtn');

        modal.classList.add('active');

        confirmBtn.onclick = async () => {
            this.showToast('Suppression complète en cours...', 'warning');

            try {
                const response = await fetch('/api/delete-template', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ code: template.code })
                });

                if (response.ok) {
                    this.templates = this.templates.filter(t => t.id !== id);
                    this.saveTemplates();
                    // Get current filter values before rendering
                    const searchQuery = document.getElementById('searchInput').value;
                    const category = document.getElementById('categoryFilter').value;
                    this.renderTemplates(searchQuery, category);
                    this.closeModal();
                    this.showToast(`Template "${template.code}" supprimé complètememt`, 'success');
                } else {
                    this.showToast('Erreur lors de la suppression sur le serveur', 'error');
                }
            } catch (e) {
                console.error(e);
                this.showToast('Erreur de connexion au serveur', 'error');
            }
        };
    }

    closeModal() {
        const modal = document.getElementById('confirmModal');
        modal.classList.remove('active');
    }

    downloadTemplate(id) {
        const template = this.templates.find(t => t.id === id);
        if (!template) return;

        // Download image
        const link = document.createElement('a');
        link.href = template.imageData;
        link.download = `${template.code}.png`;
        link.click();

        // Generate and download configuration
        this.generateTemplateFiles(template);

        this.showToast(`Fichiers pour "${template.code}" générés`, 'success');
    }

    generateTemplateFiles(template) {
        // Generate .INI file content
        const iniContent = `[Template]
Code=${template.code}
Name=${template.name}
Description=${template.description || ''}
Type=Image
PositionX=${template.positionX}
PositionY=${template.positionY}
CropTop=${template.cropTop || 0}
ImageFile=${template.code}.BMP
`;

        // Generate .BAS file content (Brother BASIC format)
        const basContent = `REM Template ${template.code} - ${template.name}
REM Generated by Template Manager

SUB Z${template.code}
    REM Display image at position
    CALL ZIMAGE("${template.code}.BMP", ${template.positionX}, ${template.positionY})
    CALL ZPRINT
END SUB
`;

        // Create downloadable files
        this.downloadTextFile(`${template.code}.INI`, iniContent);
        this.downloadTextFile(`${template.code}.BAS`, basContent);

        // Show instructions
        console.log('Template files generated:', {
            ini: iniContent,
            bas: basContent
        });
    }

    downloadTextFile(filename, content) {
        const blob = new Blob([content], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        link.click();
        URL.revokeObjectURL(url);
    }

    loadTemplates() {
        const stored = localStorage.getItem('brotherTemplates');
        if (stored) {
            try {
                const templates = JSON.parse(stored);
                // Ensure all templates have cropTop property (for backward compatibility)
                return templates.map(t => ({
                    ...t,
                    cropTop: t.cropTop || 0
                }));
            } catch (e) {
                console.error('Error loading templates:', e);
                return this.getDefaultTemplates();
            }
        }
        return this.getDefaultTemplates();
    }

    saveTemplates() {
        localStorage.setItem('brotherTemplates', JSON.stringify(this.templates));
    }

    getDefaultTemplates() {
        // Templates existants basés sur les fichiers .bmp du répertoire
        const existingTemplates = [
            // ABAT
            { code: 'ABA01', name: 'ABAT 1', category: 'ABAT' },
            { code: 'ABA02', name: 'ABAT 2', category: 'ABAT' },
            { code: 'ABA03', name: 'ABAT 3', category: 'ABAT' },

            // Amour
            { code: 'AMO01', name: 'Amour 1', category: 'Amour' },
            { code: 'AMO02', name: 'Amour 2', category: 'Amour' },
            { code: 'AMO03', name: 'Amour 3', category: 'Amour' },
            { code: 'AMO04', name: 'Amour 4', category: 'Amour' },
            { code: 'AMO05', name: 'Amour 5', category: 'Amour' },
            { code: 'AMO06', name: 'Amour 6', category: 'Amour' },

            // BARBECUE
            { code: 'BAR01', name: 'Barbecue 1', category: 'BARBECUE' },
            { code: 'BAR02', name: 'Barbecue 2', category: 'BARBECUE' },
            { code: 'BAR03', name: 'Barbecue 3', category: 'BARBECUE' },

            // Boucherie
            { code: 'BOU01', name: 'Boucherie 1', category: 'Boucherie' },
            { code: 'BOU02', name: 'Boucherie 2', category: 'Boucherie' },
            { code: 'BOU03', name: 'Boucherie 3', category: 'Boucherie' },
            { code: 'BOU04', name: 'Boucherie 4', category: 'Boucherie' },
            { code: 'BOU05', name: 'Boucherie 5', category: 'Boucherie' },
            { code: 'BOU06', name: 'Boucherie 6', category: 'Boucherie' },
            { code: 'BOU07', name: 'Boucherie 7', category: 'Boucherie' },
            { code: 'BOU10', name: 'Boucherie 10%', category: 'Boucherie' },
            { code: 'BOU11', name: 'Boucherie 11', category: 'Boucherie' },
            { code: 'BOU20', name: 'Boucherie 20%', category: 'Boucherie' },
            { code: 'BOU25', name: 'Boucherie 25%', category: 'Boucherie' },
            { code: 'BOU30', name: 'Boucherie 30%', category: 'Boucherie' },

            // Composition
            { code: 'COM01', name: 'Composition 1', category: 'Composition' },
            { code: 'COM02', name: 'Composition 2', category: 'Composition' },
            { code: 'COM03', name: 'Composition 3', category: 'Composition' },
            { code: 'COM04', name: 'Composition 4', category: 'Composition' },
            { code: 'COM05', name: 'Composition 5', category: 'Composition' },
            { code: 'COM06', name: 'Composition 6', category: 'Composition' },

            // Fêtes
            { code: 'FET01', name: 'Fête 1', category: 'Fêtes' },
            { code: 'FET02', name: 'Fête 2', category: 'Fêtes' },
            { code: 'FET03', name: 'Fête 3', category: 'Fêtes' },
            { code: 'FET04', name: 'Fête 4', category: 'Fêtes' },
            { code: 'FET05', name: 'Fête 5', category: 'Fêtes' },
            { code: 'FET06', name: 'Fête 6', category: 'Fêtes' },
            { code: 'FET07', name: 'Fête 7', category: 'Fêtes' },
            { code: 'FET08', name: 'Fête 8', category: 'Fêtes' },
            { code: 'FET09', name: 'Fête 9', category: 'Fêtes' },

            // Fraîche Découpe
            { code: 'FRA01', name: 'Fraîche Découpe 1', category: 'Fraîche Découpe' },
            { code: 'FRA02', name: 'Fraîche Découpe 2', category: 'Fraîche Découpe' },
            { code: 'FRA03', name: 'Fraîche Découpe 3', category: 'Fraîche Découpe' },

            // MAREE
            { code: 'M01', name: 'MAREE 1', category: 'MAREE' },
            { code: 'M02', name: 'MAREE 2', category: 'MAREE' },
            { code: 'M03', name: 'MAREE 3', category: 'MAREE' },
            { code: 'M04', name: 'MAREE 4', category: 'MAREE' },
            { code: 'MAR01', name: 'MAREE 01', category: 'MAREE' },
            { code: 'MAR02', name: 'MAREE 02', category: 'MAREE' },
            { code: 'MAR03', name: 'MAREE 03', category: 'MAREE' },
            { code: 'MAR04', name: 'MAREE 04', category: 'MAREE' },
            { code: 'MAR05', name: 'MAREE 05', category: 'MAREE' },
            { code: 'MAR06', name: 'MAREE 06', category: 'MAREE' },
            { code: 'MAR07', name: 'MAREE 07', category: 'MAREE' },
            { code: 'MAR08', name: 'MAREE 08', category: 'MAREE' },
            { code: 'MAR09', name: 'MAREE 09', category: 'MAREE' },

            // Origine
            { code: 'ORI01', name: 'Origine 1', category: 'Origine' },
            { code: 'ORI02', name: 'Origine 2', category: 'Origine' },

            // Pizza
            { code: 'PIZ01', name: 'Pizza 1', category: 'Pizza' },
            { code: 'PIZ02', name: 'Pizza 2', category: 'Pizza' },
            { code: 'PIZ03', name: 'Pizza 3', category: 'Pizza' },
            { code: 'PIZ04', name: 'Pizza 4', category: 'Pizza' },
            { code: 'PIZ05', name: 'Pizza 5', category: 'Pizza' },
            { code: 'PIZ06', name: 'Pizza 6', category: 'Pizza' },
            { code: 'PIZ07', name: 'Pizza 7', category: 'Pizza' },
            { code: 'PIZ08', name: 'Pizza 8', category: 'Pizza' },
            { code: 'PIZ09', name: 'Pizza 9', category: 'Pizza' },
            { code: 'PIZ10', name: 'Pizza 10', category: 'Pizza' },
            { code: 'PIZ11', name: 'Pizza 11', category: 'Pizza' },
            { code: 'PIZ12', name: 'Pizza 12', category: 'Pizza' },
            { code: 'PIZ13', name: 'Pizza 13', category: 'Pizza' },
            { code: 'PIZ14', name: 'Pizza 14', category: 'Pizza' },
            { code: 'PIZ15', name: 'Pizza 15', category: 'Pizza' },
            { code: 'PIZ16', name: 'Pizza 16', category: 'Pizza' },
            { code: 'PIZ17', name: 'Pizza 17', category: 'Pizza' },
            { code: 'PIZ18', name: 'Pizza 18', category: 'Pizza' },

            // PREPARATION
            { code: 'PRE01', name: 'PREPARATION 1', category: 'PREPARATION' },
            { code: 'PRE02', name: 'PREPARATION 2', category: 'PREPARATION' },
            { code: 'PRE03', name: 'PREPARATION 3', category: 'PREPARATION' },
            { code: 'PRE04', name: 'PREPARATION 4', category: 'PREPARATION' },
            { code: 'PRE05', name: 'PREPARATION 5', category: 'PREPARATION' },
            { code: 'PRE06', name: 'PREPARATION 6', category: 'PREPARATION' },
            { code: 'PRE07', name: 'PREPARATION 7', category: 'PREPARATION' },
            { code: 'PRE09', name: 'PREPARATION 9', category: 'PREPARATION' },
            { code: 'PRE10', name: 'PREPARATION 10', category: 'PREPARATION' },
            { code: 'PRE11', name: 'PREPARATION 11', category: 'PREPARATION' },
            { code: 'PRE12', name: 'PREPARATION 12', category: 'PREPARATION' },
            { code: 'PRE13', name: 'PREPARATION 13', category: 'PREPARATION' },
            { code: 'PRE14', name: 'PREPARATION 14', category: 'PREPARATION' },
            { code: 'PRE15', name: 'PREPARATION 15', category: 'PREPARATION' },

            // Promo
            { code: 'PR05', name: 'Promo 5%', category: 'Promo' },
            { code: 'PRO08', name: 'Promo 8', category: 'Promo' },
            { code: 'PRO09', name: 'Promo 9', category: 'Promo' },
            { code: 'PRO10', name: 'Promo 10%', category: 'Promo' },
            { code: 'PRO14', name: 'Promo 14', category: 'Promo' },
            { code: 'PRO30', name: 'Promo 30%', category: 'Promo' },
            { code: 'PRO50', name: 'Promo 50%', category: 'Promo' },
            { code: 'PRO70', name: 'Promo 70%', category: 'Promo' },
        ];

        // Convertir en format template complet avec placeholder d'image
        return existingTemplates.map((t, index) => ({
            id: Date.now() + index,
            code: t.code,
            name: t.name,
            description: `Template ${t.category}`,
            positionX: 22,
            positionY: 22,
            imageData: `${t.code.toLowerCase()}.bmp`,
            category: t.category,
            isExisting: true,
            createdAt: new Date().toISOString()
        }));
    }

    showToast(message, type = 'success') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;

        const icons = {
            success: '<polyline points="20 6 9 17 4 12"></polyline>',
            error: '<circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line>',
            warning: '<path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line>'
        };

        toast.innerHTML = `
            <svg class="toast-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                ${icons[type]}
            </svg>
            <span class="toast-message">${message}</span>
```
        // Create downloadable files
        this.downloadTextFile(`${template.code}.INI`, iniContent);
        this.downloadTextFile(`${template.code}.BAS`, basContent);

        // Show instructions
        console.log('Template files generated:', {
            ini: iniContent,
            bas: basContent
        });
    }

    downloadTextFile(filename, content) {
        const blob = new Blob([content], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        link.click();
        URL.revokeObjectURL(url);
    }

    loadTemplates() {
        const stored = localStorage.getItem('brotherTemplates');
        if (stored) {
            try {
                return JSON.parse(stored);
            } catch (e) {
                console.error('Error loading templates:', e);
                return this.getDefaultTemplates();
            }
        }
        return this.getDefaultTemplates();
    }

    saveTemplates() {
        localStorage.setItem('brotherTemplates', JSON.stringify(this.templates));
    }

    getDefaultTemplates() {
        // Templates existants basés sur les fichiers .bmp du répertoire
        const existingTemplates = [
            // ABAT
            { code: 'ABA01', name: 'ABAT 1', category: 'ABAT' },
            { code: 'ABA02', name: 'ABAT 2', category: 'ABAT' },
            { code: 'ABA03', name: 'ABAT 3', category: 'ABAT' },

            // Amour
            { code: 'AMO01', name: 'Amour 1', category: 'Amour' },
            { code: 'AMO02', name: 'Amour 2', category: 'Amour' },
            { code: 'AMO03', name: 'Amour 3', category: 'Amour' },
            { code: 'AMO04', name: 'Amour 4', category: 'Amour' },
            { code: 'AMO05', name: 'Amour 5', category: 'Amour' },
            { code: 'AMO06', name: 'Amour 6', category: 'Amour' },

            // BARBECUE
            { code: 'BAR01', name: 'Barbecue 1', category: 'BARBECUE' },
            { code: 'BAR02', name: 'Barbecue 2', category: 'BARBECUE' },
            { code: 'BAR03', name: 'Barbecue 3', category: 'BARBECUE' },

            // Boucherie
            { code: 'BOU01', name: 'Boucherie 1', category: 'Boucherie' },
            { code: 'BOU02', name: 'Boucherie 2', category: 'Boucherie' },
            { code: 'BOU03', name: 'Boucherie 3', category: 'Boucherie' },
            { code: 'BOU04', name: 'Boucherie 4', category: 'Boucherie' },
            { code: 'BOU05', name: 'Boucherie 5', category: 'Boucherie' },
            { code: 'BOU06', name: 'Boucherie 6', category: 'Boucherie' },
            { code: 'BOU07', name: 'Boucherie 7', category: 'Boucherie' },
            { code: 'BOU10', name: 'Boucherie 10%', category: 'Boucherie' },
            { code: 'BOU11', name: 'Boucherie 11', category: 'Boucherie' },
            { code: 'BOU20', name: 'Boucherie 20%', category: 'Boucherie' },
            { code: 'BOU25', name: 'Boucherie 25%', category: 'Boucherie' },
            { code: 'BOU30', name: 'Boucherie 30%', category: 'Boucherie' },

            // Composition
            { code: 'COM01', name: 'Composition 1', category: 'Composition' },
            { code: 'COM02', name: 'Composition 2', category: 'Composition' },
            { code: 'COM03', name: 'Composition 3', category: 'Composition' },
            { code: 'COM04', name: 'Composition 4', category: 'Composition' },
            { code: 'COM05', name: 'Composition 5', category: 'Composition' },
            { code: 'COM06', name: 'Composition 6', category: 'Composition' },

            // Fêtes
            { code: 'FET01', name: 'Fête 1', category: 'Fêtes' },
            { code: 'FET02', name: 'Fête 2', category: 'Fêtes' },
            { code: 'FET03', name: 'Fête 3', category: 'Fêtes' },
            { code: 'FET04', name: 'Fête 4', category: 'Fêtes' },
            { code: 'FET05', name: 'Fête 5', category: 'Fêtes' },
            { code: 'FET06', name: 'Fête 6', category: 'Fêtes' },
            { code: 'FET07', name: 'Fête 7', category: 'Fêtes' },
            { code: 'FET08', name: 'Fête 8', category: 'Fêtes' },
            { code: 'FET09', name: 'Fête 9', category: 'Fêtes' },

            // Fraîche Découpe
            { code: 'FRA01', name: 'Fraîche Découpe 1', category: 'Fraîche Découpe' },
            { code: 'FRA02', name: 'Fraîche Découpe 2', category: 'Fraîche Découpe' },
            { code: 'FRA03', name: 'Fraîche Découpe 3', category: 'Fraîche Découpe' },

            // MAREE
            { code: 'M01', name: 'MAREE 1', category: 'MAREE' },
            { code: 'M02', name: 'MAREE 2', category: 'MAREE' },
            { code: 'M03', name: 'MAREE 3', category: 'MAREE' },
            { code: 'M04', name: 'MAREE 4', category: 'MAREE' },
            { code: 'MAR01', name: 'MAREE 01', category: 'MAREE' },
            { code: 'MAR02', name: 'MAREE 02', category: 'MAREE' },
            { code: 'MAR03', name: 'MAREE 03', category: 'MAREE' },
            { code: 'MAR04', name: 'MAREE 04', category: 'MAREE' },
            { code: 'MAR05', name: 'MAREE 05', category: 'MAREE' },
            { code: 'MAR06', name: 'MAREE 06', category: 'MAREE' },
            { code: 'MAR07', name: 'MAREE 07', category: 'MAREE' },
            { code: 'MAR08', name: 'MAREE 08', category: 'MAREE' },
            { code: 'MAR09', name: 'MAREE 09', category: 'MAREE' },

            // Origine
            { code: 'ORI01', name: 'Origine 1', category: 'Origine' },
            { code: 'ORI02', name: 'Origine 2', category: 'Origine' },

            // Pizza
            { code: 'PIZ01', name: 'Pizza 1', category: 'Pizza' },
            { code: 'PIZ02', name: 'Pizza 2', category: 'Pizza' },
            { code: 'PIZ03', name: 'Pizza 3', category: 'Pizza' },
            { code: 'PIZ04', name: 'Pizza 4', category: 'Pizza' },
            { code: 'PIZ05', name: 'Pizza 5', category: 'Pizza' },
            { code: 'PIZ06', name: 'Pizza 6', category: 'Pizza' },
            { code: 'PIZ07', name: 'Pizza 7', category: 'Pizza' },
            { code: 'PIZ08', name: 'Pizza 8', category: 'Pizza' },
            { code: 'PIZ09', name: 'Pizza 9', category: 'Pizza' },
            { code: 'PIZ10', name: 'Pizza 10', category: 'Pizza' },
            { code: 'PIZ11', name: 'Pizza 11', category: 'Pizza' },
            { code: 'PIZ12', name: 'Pizza 12', category: 'Pizza' },
            { code: 'PIZ13', name: 'Pizza 13', category: 'Pizza' },
            { code: 'PIZ14', name: 'Pizza 14', category: 'Pizza' },
            { code: 'PIZ15', name: 'Pizza 15', category: 'Pizza' },
            { code: 'PIZ16', name: 'Pizza 16', category: 'Pizza' },
            { code: 'PIZ17', name: 'Pizza 17', category: 'Pizza' },
            { code: 'PIZ18', name: 'Pizza 18', category: 'Pizza' },

            // PREPARATION
            { code: 'PRE01', name: 'PREPARATION 1', category: 'PREPARATION' },
            { code: 'PRE02', name: 'PREPARATION 2', category: 'PREPARATION' },
            { code: 'PRE03', name: 'PREPARATION 3', category: 'PREPARATION' },
            { code: 'PRE04', name: 'PREPARATION 4', category: 'PREPARATION' },
            { code: 'PRE05', name: 'PREPARATION 5', category: 'PREPARATION' },
            { code: 'PRE06', name: 'PREPARATION 6', category: 'PREPARATION' },
            { code: 'PRE07', name: 'PREPARATION 7', category: 'PREPARATION' },
            { code: 'PRE09', name: 'PREPARATION 9', category: 'PREPARATION' },
            { code: 'PRE10', name: 'PREPARATION 10', category: 'PREPARATION' },
            { code: 'PRE11', name: 'PREPARATION 11', category: 'PREPARATION' },
            { code: 'PRE12', name: 'PREPARATION 12', category: 'PREPARATION' },
            { code: 'PRE13', name: 'PREPARATION 13', category: 'PREPARATION' },
            { code: 'PRE14', name: 'PREPARATION 14', category: 'PREPARATION' },
            { code: 'PRE15', name: 'PREPARATION 15', category: 'PREPARATION' },

            // Promo
            { code: 'PR05', name: 'Promo 5%', category: 'Promo' },
            { code: 'PRO08', name: 'Promo 8', category: 'Promo' },
            { code: 'PRO09', name: 'Promo 9', category: 'Promo' },
            { code: 'PRO10', name: 'Promo 10%', category: 'Promo' },
            { code: 'PRO14', name: 'Promo 14', category: 'Promo' },
            { code: 'PRO30', name: 'Promo 30%', category: 'Promo' },
            { code: 'PRO50', name: 'Promo 50%', category: 'Promo' },
            { code: 'PRO70', name: 'Promo 70%', category: 'Promo' },
        ];

        // Convertir en format template complet avec placeholder d'image
        return existingTemplates.map((t, index) => ({
            id: Date.now() + index,
            code: t.code,
            name: t.name,
            description: `Template ${t.category}`,
            positionX: 22,
            positionY: 22,
            imageData: `${t.code.toLowerCase()}.bmp`,
            category: t.category,
            isExisting: true,
            createdAt: new Date().toISOString()
        }));
    }

    showToast(message, type = 'success') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;

        const icons = {
            success: '<polyline points="20 6 9 17 4 12"></polyline>',
            error: '<circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line>',
            warning: '<path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line>'
        };

        toast.innerHTML = `
            <svg class="toast-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                ${icons[type]}
            </svg>
            <span class="toast-message">${message}</span>
        `;

        container.appendChild(toast);

        setTimeout(() => {
            toast.style.animation = 'slideInRight 0.3s ease-out reverse';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }

    convertImageTo1BitBmpBlob(img, cropTop = 0) {
        // Target size requested by user: 320x300
        const targetWidth = 320;
        const targetHeight = 300;

        // Create a canvas to resize the image
        const canvas = document.createElement('canvas');
        canvas.width = targetWidth;
        canvas.height = targetHeight;
        const ctx = canvas.getContext('2d');

        // Fill with white background
        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(0, 0, targetWidth, targetHeight);

        // Calculate scaling to fit image while maintaining aspect ratio
        const scale = Math.min(targetWidth / img.width, targetHeight / (img.height - cropTop));
        const scaledWidth = img.width * scale;
        const scaledHeight = (img.height - cropTop) * scale;

        // Center the image horizontally, align to top
        const x = (targetWidth - scaledWidth) / 2;
        const y = 0; // Align to top

        // Draw the resized image with cropping from top
        ctx.drawImage(img,
            0, cropTop, img.width, img.height - cropTop, // Source: crop from top
            x, y, scaledWidth, scaledHeight              // Destination: scaled
        );

        // Get raw pixel data
        const imageData = ctx.getImageData(0, 0, targetWidth, targetHeight);
        const data = imageData.data;

        // BMP Header Construction
        const rowSize = Math.ceil(targetWidth / 32) * 4; // Row size in bytes (padded to 4 bytes)
        const pixelArraySize = rowSize * targetHeight;
        const fileSize = 54 + 8 + pixelArraySize; // Header (54) + Palette (8) + Pixels

        const buffer = new ArrayBuffer(fileSize);
        const view = new DataView(buffer);

        // BMP Header
        view.setUint16(0, 0x424D, false); // "BM"
        view.setUint32(2, fileSize, true); // File size
        view.setUint32(6, 0, true); // Reserved
        view.setUint32(10, 62, true); // Offset to pixel data (54 + 8 palette)

        // DIB Header
        view.setUint32(14, 40, true); // Header size
        view.setInt32(18, targetWidth, true); // Width
        view.setInt32(22, targetHeight, true); // Height (POSITIVE for Bottom-Up)
        view.setUint16(26, 1, true); // Planes
        view.setUint16(28, 1, true); // Bits per pixel (1-bit)
        view.setUint32(30, 0, true); // Compression (BI_RGB)
        view.setUint32(34, pixelArraySize, true); // Image size
        view.setInt32(38, 8000, true); // X pixels per meter (~203 DPI)
        view.setInt32(42, 8000, true); // Y pixels per meter (~203 DPI)
        view.setUint32(46, 2, true); // Colors in palette
        view.setUint32(50, 0, true); // Important colors

        // Palette (Color Table)
        // Color 0: Black (00 00 00 00)
        view.setUint32(54, 0x00000000, true);
        // Color 1: White (FF FF FF 00)
        view.setUint32(58, 0x00FFFFFF, true);

        // Pixel Data (1-bit conversion)
        // Width is 320, which is perfectly divisible by 32 (320/32 = 10 blocks)
        // So rowSize is exactly 40 bytes (320 bits / 8), no padding needed for this specific width,
        // but logic handles padding anyway.

        // Standard BMP stores rows from Bottom to Top
        let offset = 62;
        for (let y = targetHeight - 1; y >= 0; y--) {
            let bitBuffer = 0;
            let bitsWritten = 0;

            for (let x = 0; x < targetWidth; x++) {
                const idx = (y * targetWidth + x) * 4;
                // Greyscale: 0.299R + 0.587G + 0.114B
                const gray = data[idx] * 0.299 + data[idx + 1] * 0.587 + data[idx + 2] * 0.114;

                // Thresholding: Black (0) if < 128, White (1) if >= 128
                const bit = gray < 128 ? 0 : 1;

                bitBuffer = (bitBuffer << 1) | bit;
                bitsWritten++;

                if (bitsWritten === 8) {
                    view.setUint8(offset++, bitBuffer);
                    bitBuffer = 0;
                    bitsWritten = 0;
                }
            }

            // Pad remaining bits in the last byte of the row
            if (bitsWritten > 0) {
                bitBuffer = bitBuffer << (8 - bitsWritten);
                view.setUint8(offset++, bitBuffer);
            }

            // Padding to 4-byte boundary (if necessary)
            while ((offset - 62) % 4 !== 0) {
                view.setUint8(offset++, 0);
            }
        }

        return new Blob([buffer], { type: 'image/bmp' });
    }

    async generateManual() {
        this.showToast('Génération du manuel en cours...', 'warning');

        try {
            const response = await fetch('/api/generate-manual', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });

            const result = await response.json();

            if (response.ok) {
                this.showToast(`Manuel généré avec succès : ${result.totalTemplates} templates`, 'success');

                // Ouvrir le manuel généré dans un nouvel onglet
                setTimeout(() => {
                    window.open('manuel_brother_td4t_generated.html', '_blank');
                }, 1000);
            } else {
                this.showToast(`Erreur : ${result.error}`, 'error');
            }
        } catch (error) {
            console.error('Error generating manual:', error);
            this.showToast('Erreur de connexion au serveur', 'error');
        }
    }
}

// Initialize when DOM is ready
let templateManager;
document.addEventListener('DOMContentLoaded', () => {
    templateManager = new TemplateManager();
});

// Global function for modal close
function closeModal() {
    if (templateManager) {
        templateManager.closeModal();
    }
}

// Global function to open manual
function openManual() {
    window.open('manuel_brother_td4t_generated.html', '_blank');
}
