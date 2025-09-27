let characters = [];
let selectedChar = null;
let locales = {};
let deleteButtonEnabled = false;
let canCreateChar = false;

const show = (elementId) => {
    const el = document.getElementById(elementId);
    if (el) el.style.display = 'block';
}

const hide = (elementId) => {
    const el = document.getElementById(elementId);
    if (el) el.style.display = 'none';
}

// Update the post function with error handling
const post = async (name, data = {}) => {
    try {
        const resourceName = GetParentResourceName();
        await fetch(`https://${resourceName}/${name}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        }).catch(() => {
            // FiveM NUI expected behavior - ignore the error
        });
    } catch (err) {
        // Silence the error since this is expected behavior in FiveM NUI
        return;
    }
}

const setLocales = () => {
    document.querySelectorAll('[data-locale]').forEach(element => {
        const key = element.getAttribute('data-locale');
        if (locales[key]) element.textContent = locales[key];
    });

    document.querySelectorAll('[data-locale-placeholder]').forEach(element => {
        const key = element.getAttribute('data-locale-placeholder');
        if (locales[key]) element.placeholder = locales[key];
    });
}

// Update the createCharacterSlot function to better handle job and money data
const createCharacterSlot = (char) => {
    const money = char.money || { cash: 0, bank: 0 };
    return `
    <div class="character-slot" data-cid="${char.citizenid}">
        <div class="character-header">
            <div class="name-row">
                <i class="fas fa-user-circle"></i>
                <div>
                    <div class="char-name">${char.displayName || (char.firstname + ' ' + char.lastname)}</div>
                    <div class="char-sub">ID: ${char.citizenid}</div>
                </div>
            </div>
            <div style="display:flex;align-items:center;gap:8px">
                <div class="char-sub" style="font-size:12px">${char.job || 'Unemployed'}</div>
                <i class="chev fas fa-chevron-down"></i>
            </div>
        </div>

        <div class="character-info">
            <div class="character-details">
                <div class="detail-item">
                    <i class="fas fa-briefcase"></i>
                    <span>Job: ${char.job || 'Unemployed'}</span>
                </div>
                <div class="detail-item">
                    <i class="fas fa-wallet"></i>
                    <span>Cash: $${(money.cash || 0).toLocaleString()}</span>
                </div>
                <div class="detail-item">
                    <i class="fas fa-university"></i>
                    <span>Bank: $${(money.bank || 0).toLocaleString()}</span>
                </div>
                <div class="character-actions">
                    <button class="button play-button" data-locale="spawn"><i class="fas fa-play"></i>&nbsp;${locales.spawn || 'Play'}</button>
                    ${deleteButtonEnabled ? `<button class="button danger delete-button" data-locale="delete"><i class="fas fa-trash"></i>&nbsp;${locales.delete || 'Delete'}</button>` : ''}
                </div>
            </div>
        </div>
    </div>
    `;
}

const setupListeners = () => {
    // Character selection / dropdown toggle (toggle behavior)
    document.querySelectorAll('.character-slot').forEach(slot => {
        slot.addEventListener('click', (ev) => {
            if (ev.target.closest('.button')) return; // ignore button clicks
            const cid = slot.getAttribute('data-cid');
            const isActive = slot.classList.contains('active');
            // collapse all
            document.querySelectorAll('.character-slot').forEach(s => s.classList.remove('selected','active'));
            if (!isActive) {
                // open clicked
                slot.classList.add('selected','active');
                selectedChar = cid;
                post('selectChar', { citizenid: cid });
                slot.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            } else {
                // was active, now collapsed
                selectedChar = null;
            }
        });
    });

    // Play button
    document.querySelectorAll('.play-button').forEach(button => {
        button.addEventListener('click', (e) => {
            e.stopPropagation();
            const cid = button.closest('.character-slot').getAttribute('data-cid');
            post('spawnChar', { citizenid: cid });
        });
    });

    // Delete button
    document.querySelectorAll('.delete-button').forEach(button => {
        button.addEventListener('click', (e) => {
            e.stopPropagation();
            const cid = button.closest('.character-slot').getAttribute('data-cid');
            if (confirm(locales.confirm_delete || 'Confirm delete?')) {
                post('deleteChar', { citizenid: cid });
            }
        });
    });

    // Create new character (only if allowed)
    const createNewEl = document.getElementById('create-new');
    if (createNewEl) {
        if (!canCreateChar) {
            createNewEl.style.display = 'none';
        } else {
            createNewEl.style.display = 'flex';
            createNewEl.addEventListener('click', () => {
                hide('multichar');
                show('creation');
                // focus first input
                setTimeout(() => { const f = document.getElementById('firstname'); if(f) f.focus(); }, 80);
            });
        }
    }

    // Create character form with basic validation
    const createBtn = document.getElementById('create');
    if (createBtn) {
        createBtn.addEventListener('click', () => {
            const firstname = (document.getElementById('firstname').value || '').trim();
            const lastname = (document.getElementById('lastname').value || '').trim();
            if (firstname.length < 2 || lastname.length < 2) {
                return alert('Please enter a valid first and last name.');
            }
            const data = {
                firstname,
                lastname,
                nationality: document.getElementById('nationality').value,
                gender: document.getElementById('gender').value,
                birthdate: document.getElementById('birthdate').value
            };
            // create and auto-close UI (server will handle spawn flow)
            post('createChar', data);
            hide('creation');
            show('multichar');
        });
    }

    // Cancel creation
    const cancelBtn = document.getElementById('cancel');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => {
            hide('creation');
            show('multichar');
        });
    }

    // close/back buttons
    const closeBtn = document.getElementById('close-btn');
    if (closeBtn) closeBtn.addEventListener('click', () => post('hideFrame', { name: 'setVisibleMultichar' }));

    const backBtn = document.getElementById('back-btn');
    if (backBtn) backBtn.addEventListener('click', () => {
        show('multichar'); hide('creation');
    });
}

window.addEventListener('message', (event) => {
    const { action, data } = event.data;

    switch (action) {
        case 'setVisibleMultichar':
            if (data) {
                show('app');
                show('multichar');
            } else {
                hide('app');
            }
            break;

        case 'selectChar':
            // incoming from client: expand/select the provided citizenid
            if (data && data.citizenid) {
                const slot = document.querySelector(`.character-slot[data-cid="${data.citizenid}"]`);
                if (slot) {
                    document.querySelectorAll('.character-slot').forEach(s => s.classList.remove('selected','active'));
                    slot.classList.add('selected','active');
                    slot.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                }
            }
            break;

        case 'multichar':
            // Data sent from client: characters, nationalities, deleteButton, canCreateChar, locales
            characters = data.characters || [];
            locales = data.locales || {};
            deleteButtonEnabled = !!data.deleteButton;
            canCreateChar = !!data.canCreateChar;
            
            // Populate characters
            const charactersHTML = characters.map(char => createCharacterSlot(char)).join('');
            document.getElementById('characters').innerHTML = charactersHTML;
            
            // Populate nationalities
            const nationalitiesHTML = (data.nationalities || []).map(n => `<option value="${n}">${n}</option>`).join('');
            const natEl = document.getElementById('nationality');
            if (natEl) natEl.innerHTML = nationalitiesHTML;
            
            setLocales();
            setupListeners();
            break;
    }
});