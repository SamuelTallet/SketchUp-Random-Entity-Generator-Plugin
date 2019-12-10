/**
 * REG Proxy Library Explorer.
 *
 * @package REG extension for SketchUp
 *
 * @copyright © 2019 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * REG plugin namespace.
 */
REG = {};

/**
 * Listens to "proxy import" button click.
 */
REG.listenToProxyImportButtons = () => {

	let proxyImportButtons = document.querySelectorAll('.reg-proxy-import-button');

	proxyImportButtons.forEach(proxyImportButton => {

		proxyImportButton.addEventListener('click', event => {

			sketchup.importProxy(event.currentTarget.dataset.proxyRef);

		});

	});

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

	REG.listenToProxyImportButtons();

});
