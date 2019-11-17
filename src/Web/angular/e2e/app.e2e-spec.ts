import { PiggyvaultTemplatePage } from './app.po';

describe('Piggyvault App', function() {
  let page: PiggyvaultTemplatePage;

  beforeEach(() => {
    page = new PiggyvaultTemplatePage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
